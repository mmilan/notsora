import Foundation

enum FFmpegCommandBuilder {
    static func buildArguments(
        inputURL: URL,
        outputURL: URL,
        settings: CompressionSettings,
        metadata: MetadataFields
    ) -> [String] {
        var args: [String] = []

        // Overwrite without asking
        args.append("-y")

        // Enable progress output
        args.append(contentsOf: ["-progress", "pipe:2"])

        // Input
        args.append(contentsOf: ["-i", inputURL.path])

        // Video codec
        args.append(contentsOf: ["-c:v", settings.videoCodec.rawValue])

        // Encoding preset
        args.append(contentsOf: ["-preset", settings.preset])

        // Quality mode
        switch settings.qualityMode {
        case .crf:
            args.append(contentsOf: ["-crf", String(settings.crfValue)])
        case .bitrate:
            args.append(contentsOf: ["-b:v", "\(settings.videoBitrate)k"])
        }

        // Pixel format
        args.append(contentsOf: ["-pix_fmt", settings.pixelFormat])

        // Profile and level
        args.append(contentsOf: ["-profile:v", settings.videoCodec.profile])
        args.append(contentsOf: ["-level", settings.videoCodec.level])

        // Scale filter for resolution
        if let scaleFilter = settings.resolution.scaleFilter {
            args.append(contentsOf: ["-vf", scaleFilter])
        }

        // Audio codec
        args.append(contentsOf: ["-c:a", settings.audioCodec.rawValue])
        args.append(contentsOf: ["-b:a", "\(settings.audioBitrate)k"])

        // Movflags for faststart (MP4 only)
        if settings.container.supportsMovflags && settings.fastStart {
            args.append(contentsOf: ["-movflags", "+faststart"])
        }

        // Metadata
        args.append(contentsOf: metadata.ffmpegArguments)

        // Output
        args.append(outputURL.path)

        return args
    }
}
