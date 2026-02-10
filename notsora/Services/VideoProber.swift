import Foundation

struct ProbeResult {
    var duration: Double = 0
    var width: Int = 0
    var height: Int = 0
    var videoCodec: String = ""
    var audioCodec: String = ""
    var framerate: Double = 0
}

enum VideoProber {
    static func probe(url: URL) async throws -> ProbeResult {
        let ffprobeURL = AppConstants.ffprobeURL

        guard FileManager.default.fileExists(atPath: ffprobeURL.path) else {
            throw ProbeError.ffprobeNotFound
        }

        let process = Process()
        process.executableURL = ffprobeURL
        process.arguments = [
            "-v", "quiet",
            "-print_format", "json",
            "-show_format",
            "-show_streams",
            url.path
        ]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        return try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { _ in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()

                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    continuation.resume(throwing: ProbeError.parseError)
                    return
                }

                var result = ProbeResult()

                // Parse format duration
                if let format = json["format"] as? [String: Any],
                   let durationStr = format["duration"] as? String,
                   let duration = Double(durationStr) {
                    result.duration = duration
                }

                // Parse streams
                if let streams = json["streams"] as? [[String: Any]] {
                    for stream in streams {
                        let codecType = stream["codec_type"] as? String ?? ""

                        if codecType == "video" && result.videoCodec.isEmpty {
                            result.videoCodec = stream["codec_name"] as? String ?? ""
                            result.width = stream["width"] as? Int ?? 0
                            result.height = stream["height"] as? Int ?? 0

                            // Parse framerate from r_frame_rate (e.g., "30000/1001")
                            if let rFrameRate = stream["r_frame_rate"] as? String {
                                let parts = rFrameRate.split(separator: "/")
                                if parts.count == 2,
                                   let num = Double(parts[0]),
                                   let den = Double(parts[1]),
                                   den > 0 {
                                    result.framerate = num / den
                                }
                            }

                            // Fallback duration from video stream
                            if result.duration == 0,
                               let durationStr = stream["duration"] as? String,
                               let duration = Double(durationStr) {
                                result.duration = duration
                            }
                        }

                        if codecType == "audio" && result.audioCodec.isEmpty {
                            result.audioCodec = stream["codec_name"] as? String ?? ""
                        }
                    }
                }

                continuation.resume(returning: result)
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: ProbeError.launchFailed(error))
            }
        }
    }

    enum ProbeError: LocalizedError {
        case ffprobeNotFound
        case parseError
        case launchFailed(Error)

        var errorDescription: String? {
            switch self {
            case .ffprobeNotFound:
                return "ffprobe binary not found in app bundle."
            case .parseError:
                return "Failed to parse ffprobe output."
            case .launchFailed(let error):
                return "Failed to launch ffprobe: \(error.localizedDescription)"
            }
        }
    }
}
