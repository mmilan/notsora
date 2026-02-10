import Foundation

struct CompressionSettings: Codable, Equatable {
    var resolution: TargetResolution = .p1080
    var videoCodec: VideoCodec = .h264
    var audioCodec: AudioCodec = .aac
    var qualityMode: QualityMode = .crf
    var crfValue: Int = 23
    var videoBitrate: Int = 5000 // kbps
    var audioBitrate: Int = 192 // kbps
    var preset: String = "medium"
    var container: ContainerFormat = .mp4
    var pixelFormat: String = "yuv420p"
    var fastStart: Bool = true

    var validationWarnings: [String] {
        var warnings: [String] = []

        if audioCodec == .opus && container == .mp4 {
            warnings.append("Opus audio is not compatible with MP4 container. Use MKV or WebM.")
        }

        if videoCodec == .h265 {
            warnings.append("H.265 is not supported by Firefox and some older Android devices.")
        }

        if container == .webm && videoCodec == .h264 {
            warnings.append("WebM container does not support H.264. Use VP9 or switch to MP4/MKV.")
        }

        return warnings
    }

    var hasErrors: Bool {
        (audioCodec == .opus && container == .mp4) ||
        (container == .webm && videoCodec == .h264)
    }
}
