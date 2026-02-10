import Foundation

enum JobStatus: String {
    case pending = "Pending"
    case running = "Compressing"
    case completed = "Completed"
    case failed = "Failed"
    case cancelled = "Cancelled"

    var badgeColor: String {
        switch self {
        case .pending: return "secondary"
        case .running: return "blue"
        case .completed: return "green"
        case .failed: return "red"
        case .cancelled: return "orange"
        }
    }
}

@Observable
final class CompressionJob: Identifiable {
    let id = UUID()
    let videoFile: VideoFile
    let settings: CompressionSettings
    let metadata: MetadataFields
    let outputURL: URL
    let outputFilename: String

    var status: JobStatus = .pending
    var progress: Double = 0.0 // 0.0 to 1.0
    var currentTime: Double = 0.0
    var estimatedTimeRemaining: Double?
    var startTime: Date?
    var endTime: Date?
    var outputFileSize: Int64?
    var errorMessage: String?

    var process: Process?

    init(videoFile: VideoFile, settings: CompressionSettings, metadata: MetadataFields, outputURL: URL, outputFilename: String) {
        self.videoFile = videoFile
        self.settings = settings
        self.metadata = metadata
        self.outputURL = outputURL
        self.outputFilename = outputFilename
    }

    var outputFileSizeFormatted: String? {
        guard let size = outputFileSize else { return nil }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    var etaFormatted: String? {
        guard let eta = estimatedTimeRemaining, eta > 0 else { return nil }
        let minutes = Int(eta) / 60
        let seconds = Int(eta) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s remaining"
        }
        return "\(seconds)s remaining"
    }

    var elapsedFormatted: String? {
        guard let start = startTime else { return nil }
        let end = endTime ?? Date()
        let elapsed = end.timeIntervalSince(start)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}
