import Foundation

enum VideoCodec: String, CaseIterable, Identifiable, Codable {
    case h264 = "libx264"
    case h265 = "libx265"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .h264: return "H.264 (Recommended)"
        case .h265: return "H.265 (HEVC)"
        }
    }

    var defaultCRF: Int {
        switch self {
        case .h264: return 23
        case .h265: return 28
        }
    }

    var crfRange: ClosedRange<Int> {
        switch self {
        case .h264: return 0...51
        case .h265: return 0...51
        }
    }

    var profile: String {
        switch self {
        case .h264: return "high"
        case .h265: return "main"
        }
    }

    var level: String {
        switch self {
        case .h264: return "4.1"
        case .h265: return "4.0"
        }
    }
}
