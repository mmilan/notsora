import Foundation

enum TargetResolution: String, CaseIterable, Identifiable, Codable {
    case original = "Original"
    case p1080 = "1080p"
    case p720 = "720p"

    var id: String { rawValue }

    var height: Int? {
        switch self {
        case .original: return nil
        case .p1080: return 1080
        case .p720: return 720
        }
    }

    /// Scale filter that prevents upscaling and ensures even dimensions
    var scaleFilter: String? {
        guard let h = height else { return nil }
        return "scale='min(\(h)*dar\\,iw)':min(\(h)\\,ih):force_original_aspect_ratio=decrease,scale=trunc(iw/2)*2:trunc(ih/2)*2"
    }
}
