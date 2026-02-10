import SwiftUI

struct VideoDetailView: View {
    let video: VideoFile
    @Bindable var viewModel: VideoListViewModel

    @State private var settings: CompressionSettings
    @State private var metadata: MetadataFields

    init(video: VideoFile, viewModel: VideoListViewModel) {
        self.video = video
        self.viewModel = viewModel
        self._settings = State(initialValue: viewModel.settingsFor(video))
        self._metadata = State(initialValue: viewModel.metadataFor(video))
    }

    var body: some View {
        Form {
            // Source file info
            Section("Source File") {
                LabeledContent("Resolution", value: video.resolutionString)
                LabeledContent("Duration", value: video.durationFormatted)
                LabeledContent("File Size", value: video.fileSizeFormatted)
                if !video.videoCodec.isEmpty {
                    LabeledContent("Video Codec", value: video.videoCodec)
                }
                if !video.audioCodec.isEmpty {
                    LabeledContent("Audio Codec", value: video.audioCodec)
                }
                if video.framerate > 0 {
                    LabeledContent("Frame Rate", value: String(format: "%.2f fps", video.framerate))
                }
            }

            // Output settings
            OutputSettingsView(video: video, viewModel: viewModel)

            // Compression settings
            CompressionSettingsView(settings: $settings)
                .onChange(of: settings) { _, newSettings in
                    viewModel.updateSettings(newSettings, for: video)
                }

            // Metadata
            MetadataEditorView(metadata: $metadata)
                .onChange(of: metadata) { _, newMetadata in
                    viewModel.updateMetadata(newMetadata, for: video)
                }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle(video.filename)
        .onChange(of: video.id) { _, _ in
            settings = viewModel.settingsFor(video)
            metadata = viewModel.metadataFor(video)
        }
    }
}
