import Foundation

enum FFmpegError: LocalizedError {
    case ffmpegNotFound
    case processFailed(Int32, String)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .ffmpegNotFound:
            return "ffmpeg binary not found in app bundle."
        case .processFailed(let code, let stderr):
            return "ffmpeg exited with code \(code): \(stderr)"
        case .cancelled:
            return "Compression was cancelled."
        }
    }
}

private final class StderrCollector: @unchecked Sendable {
    private let lock = NSLock()
    private var _output = ""

    var output: String {
        lock.lock()
        defer { lock.unlock() }
        return _output
    }

    func append(_ text: String) {
        lock.lock()
        defer { lock.unlock() }
        _output += text
    }
}

actor FFmpegRunner {
    static let shared = FFmpegRunner()

    func run(
        job: CompressionJob,
        onProgress: @Sendable @escaping (Double, Double) -> Void
    ) async throws {
        let ffmpegURL = AppConstants.ffmpegURL

        guard FileManager.default.fileExists(atPath: ffmpegURL.path) else {
            throw FFmpegError.ffmpegNotFound
        }

        let arguments = FFmpegCommandBuilder.buildArguments(
            inputURL: job.videoFile.url,
            outputURL: job.outputURL.appendingPathComponent(job.outputFilename),
            settings: job.settings,
            metadata: job.metadata
        )

        let process = Process()
        process.executableURL = ffmpegURL
        process.arguments = arguments
        process.standardOutput = Pipe()

        let stderrPipe = Pipe()
        process.standardError = stderrPipe

        // Store process reference for cancellation
        await MainActor.run {
            job.process = process
        }

        let stderrCollector = StderrCollector()
        let totalDuration = job.videoFile.duration

        // Set up stderr reading for progress
        stderrPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let line = String(data: data, encoding: .utf8) else { return }

            stderrCollector.append(line)

            if let currentTime = FFmpegProgressParser.parseTime(from: line) {
                let fraction = FFmpegProgressParser.progressFraction(
                    currentTime: currentTime,
                    totalDuration: totalDuration
                )
                onProgress(fraction, currentTime)
            }
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            process.terminationHandler = { proc in
                stderrPipe.fileHandleForReading.readabilityHandler = nil

                if proc.terminationReason == .uncaughtSignal {
                    continuation.resume(throwing: FFmpegError.cancelled)
                } else if proc.terminationStatus != 0 {
                    let lines = stderrCollector.output.split(separator: "\n").suffix(5).joined(separator: "\n")
                    continuation.resume(throwing: FFmpegError.processFailed(proc.terminationStatus, lines))
                } else {
                    continuation.resume()
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func cancel(job: CompressionJob) async {
        await MainActor.run {
            if let process = job.process, process.isRunning {
                process.interrupt() // SIGINT for graceful exit
            }
        }
    }

    static func checkBinariesExist() -> (ffmpeg: Bool, ffprobe: Bool) {
        let fm = FileManager.default
        return (
            ffmpeg: fm.isExecutableFile(atPath: AppConstants.ffmpegURL.path),
            ffprobe: fm.isExecutableFile(atPath: AppConstants.ffprobeURL.path)
        )
    }
}
