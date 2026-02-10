import Foundation

enum QualityMode: String, CaseIterable, Identifiable, Codable {
    case crf = "CRF (Constant Quality)"
    case bitrate = "Bitrate (Constant)"

    var id: String { rawValue }

    var displayName: String { rawValue }
}

enum ContainerFormat: String, CaseIterable, Identifiable, Codable {
    case mp4 = "mp4"
    case mkv = "mkv"
    case webm = "webm"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .mp4: return "MP4 (Recommended)"
        case .mkv: return "MKV"
        case .webm: return "WebM"
        }
    }

    var fileExtension: String { rawValue }

    var supportsMovflags: Bool {
        self == .mp4
    }
}
