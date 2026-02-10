import Foundation

enum AppConstants {
    static let supportedExtensions: Set<String> = [
        "mp4", "mov", "avi", "mkv", "wmv", "flv", "webm", "m4v", "mpg", "mpeg", "3gp", "ts", "mts"
    ]

    /// Resolves ffmpeg binary: bundled in Resources first, then Homebrew fallback for development.
    static var ffmpegURL: URL {
        let bundled = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/ffmpeg")
        if FileManager.default.fileExists(atPath: bundled.path) {
            return bundled
        }
        // Homebrew fallback for development without bundled binaries
        let homebrew = URL(fileURLWithPath: "/opt/homebrew/bin/ffmpeg")
        if FileManager.default.fileExists(atPath: homebrew.path) {
            return homebrew
        }
        let usrLocal = URL(fileURLWithPath: "/usr/local/bin/ffmpeg")
        if FileManager.default.fileExists(atPath: usrLocal.path) {
            return usrLocal
        }
        return bundled // Return bundled path (will fail with descriptive error)
    }

    /// Resolves ffprobe binary: bundled in Resources first, then Homebrew fallback for development.
    static var ffprobeURL: URL {
        let bundled = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/ffprobe")
        if FileManager.default.fileExists(atPath: bundled.path) {
            return bundled
        }
        let homebrew = URL(fileURLWithPath: "/opt/homebrew/bin/ffprobe")
        if FileManager.default.fileExists(atPath: homebrew.path) {
            return homebrew
        }
        let usrLocal = URL(fileURLWithPath: "/usr/local/bin/ffprobe")
        if FileManager.default.fileExists(atPath: usrLocal.path) {
            return usrLocal
        }
        return bundled
    }

    static let defaultCRF: Int = 23
    static let defaultAudioBitrate: Int = 192
    static let defaultPreset: String = "medium"

    static let presets: [String] = [
        "ultrafast", "superfast", "veryfast", "faster", "fast",
        "medium", "slow", "slower", "veryslow"
    ]
}
