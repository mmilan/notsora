import Foundation

@Observable
final class CompressionViewModel {
    var jobs: [CompressionJob] = []
    var isCompressing = false
    var showProgressSheet = false
    var currentJobIndex = 0

    var overallProgress: Double {
        guard !jobs.isEmpty else { return 0 }
        let total = jobs.reduce(0.0) { sum, job in
            switch job.status {
            case .completed: return sum + 1.0
            case .running: return sum + job.progress
            case .cancelled, .failed: return sum + 0.0
            default: return sum
            }
        }
        return total / Double(jobs.count)
    }

    var completedCount: Int {
        jobs.filter { $0.status == .completed }.count
    }

    var failedCount: Int {
        jobs.filter { $0.status == .failed }.count
    }

    func startCompression(videoList: VideoListViewModel) {
        guard let outputDir = videoList.outputDirectory else { return }
        guard !videoList.videos.isEmpty else { return }

        // Build jobs
        jobs = videoList.videos.map { video in
            CompressionJob(
                videoFile: video,
                settings: videoList.settingsFor(video),
                metadata: videoList.metadataFor(video),
                outputURL: outputDir,
                outputFilename: videoList.outputFilenameFor(video)
            )
        }

        isCompressing = true
        showProgressSheet = true
        currentJobIndex = 0

        Task {
            await runJobs()
        }
    }

    private func runJobs() async {
        for (index, job) in jobs.enumerated() {
            guard isCompressing else {
                // Mark remaining as cancelled
                for remaining in jobs[index...] where remaining.status == .pending {
                    await MainActor.run {
                        remaining.status = .cancelled
                    }
                }
                break
            }

            await MainActor.run {
                currentJobIndex = index
                job.status = .running
                job.startTime = Date()
            }

            do {
                try await FFmpegRunner.shared.run(job: job) { [weak job] progress, currentTime in
                    guard let job else { return }
                    Task { @MainActor in
                        job.progress = progress
                        job.currentTime = currentTime

                        if let start = job.startTime {
                            let elapsed = Date().timeIntervalSince(start)
                            job.estimatedTimeRemaining = FFmpegProgressParser.estimateTimeRemaining(
                                elapsed: elapsed,
                                progress: progress
                            )
                        }
                    }
                }

                await MainActor.run {
                    job.status = .completed
                    job.progress = 1.0
                    job.endTime = Date()

                    // Get output file size
                    let outputPath = job.outputURL.appendingPathComponent(job.outputFilename).path
                    if let attrs = try? FileManager.default.attributesOfItem(atPath: outputPath),
                       let size = attrs[.size] as? Int64 {
                        job.outputFileSize = size
                    }
                }
            } catch is CancellationError {
                await MainActor.run {
                    job.status = .cancelled
                    job.endTime = Date()
                }
            } catch {
                await MainActor.run {
                    job.status = .failed
                    job.errorMessage = error.localizedDescription
                    job.endTime = Date()
                }
            }
        }

        await MainActor.run {
            isCompressing = false
        }
    }

    func cancelAll() {
        isCompressing = false

        for job in jobs where job.status == .running {
            Task {
                await FFmpegRunner.shared.cancel(job: job)
            }
        }

        for job in jobs where job.status == .pending {
            job.status = .cancelled
        }
    }

    func dismissProgress() {
        showProgressSheet = false
        jobs = []
    }
}
