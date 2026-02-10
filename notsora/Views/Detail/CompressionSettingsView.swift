import SwiftUI

struct CompressionSettingsView: View {
    @Binding var settings: CompressionSettings

    var body: some View {
        Section("Compression Settings") {
            // Resolution
            Picker("Resolution", selection: $settings.resolution) {
                ForEach(TargetResolution.allCases) { res in
                    Text(res.rawValue).tag(res)
                }
            }
            .pickerStyle(.segmented)

            // Video codec
            Picker("Video Codec", selection: $settings.videoCodec) {
                ForEach(VideoCodec.allCases) { codec in
                    Text(codec.displayName).tag(codec)
                }
            }
            .tint(Theme.twitterBlue)
            .onChange(of: settings.videoCodec) { _, newCodec in
                settings.crfValue = newCodec.defaultCRF
            }

            // Audio codec
            Picker("Audio Codec", selection: $settings.audioCodec) {
                ForEach(AudioCodec.allCases) { codec in
                    Text(codec.displayName).tag(codec)
                }
            }
            .tint(Theme.twitterBlue)
            .onChange(of: settings.audioCodec) { _, newCodec in
                settings.audioBitrate = newCodec.defaultBitrate
            }

            // Quality mode
            Picker("Quality Mode", selection: $settings.qualityMode) {
                ForEach(QualityMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .tint(Theme.twitterBlue)

            // CRF or Bitrate slider
            switch settings.qualityMode {
            case .crf:
                LabeledSlider(
                    title: "CRF",
                    value: $settings.crfValue,
                    range: settings.videoCodec.crfRange,
                    valueLabel: "\(settings.crfValue) (lower = better quality)"
                )
            case .bitrate:
                LabeledSlider(
                    title: "Video Bitrate",
                    value: $settings.videoBitrate,
                    range: 500...20000,
                    step: 100,
                    valueLabel: "\(settings.videoBitrate) kbps"
                )
            }

            // Audio bitrate
            LabeledSlider(
                title: "Audio Bitrate",
                value: $settings.audioBitrate,
                range: settings.audioCodec.bitrateRange,
                step: 16,
                valueLabel: "\(settings.audioBitrate) kbps"
            )

            // Encoding preset
            Picker("Encoding Preset", selection: $settings.preset) {
                ForEach(AppConstants.presets, id: \.self) { preset in
                    Text(preset).tag(preset)
                }
            }
            .tint(Theme.twitterBlue)

            // Container format
            Picker("Container Format", selection: $settings.container) {
                ForEach(ContainerFormat.allCases) { container in
                    Text(container.displayName).tag(container)
                }
            }
            .tint(Theme.twitterBlue)

            // Fast start toggle (MP4 only)
            if settings.container.supportsMovflags {
                Toggle("Fast Start (Progressive Streaming)", isOn: $settings.fastStart)
                    .tint(Theme.twitterBlue)
            }

            // Validation warnings
            ForEach(settings.validationWarnings, id: \.self) { warning in
                Label(warning, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(Theme.warning)
                    .font(.caption)
            }
        }
    }
}
