import Foundation

struct VideoFile: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let filename: String
    let fileSize: Int64
    var duration: Double = 0
    var width: Int = 0
    var height: Int = 0
    var videoCodec: String = ""
    var audioCodec: String = ""
    var framerate: Double = 0

    var fileSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }

    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    var resolutionString: String {
        guard width > 0, height > 0 else { return "Unknown" }
        return "\(width)×\(height)"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: VideoFile, rhs: VideoFile) -> Bool {
        lhs.id == rhs.id
    }
}
