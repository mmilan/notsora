import Foundation

enum AudioCodec: String, CaseIterable, Identifiable, Codable {
    case aac = "aac"
    case opus = "libopus"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .aac: return "AAC (Recommended)"
        case .opus: return "Opus"
        }
    }

    var defaultBitrate: Int {
        switch self {
        case .aac: return 192
        case .opus: return 128
        }
    }

    var bitrateRange: ClosedRange<Int> {
        switch self {
        case .aac: return 64...320
        case .opus: return 32...256
        }
    }

    var compatibleContainers: Set<ContainerFormat> {
        switch self {
        case .aac: return [.mp4, .mkv]
        case .opus: return [.mkv, .webm]
        }
    }
}
