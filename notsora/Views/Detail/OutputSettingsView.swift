import SwiftUI

struct OutputSettingsView: View {
    let video: VideoFile
    @Bindable var viewModel: VideoListViewModel

    var body: some View {
        Section("Output") {
            LabeledContent("Filename") {
                TextField("Output filename", text: Binding(
                    get: { viewModel.outputFilenameFor(video) },
                    set: { viewModel.updateOutputFilename($0, for: video) }
                ))
                .textFieldStyle(.roundedBorder)
            }

            LabeledContent("Output Folder") {
                HStack {
                    if let dir = viewModel.outputDirectory {
                        Text(dir.lastPathComponent)
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.head)
                    } else {
                        Text("Not selected")
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Button("Choose…") {
                        viewModel.showOutputDirectoryPicker()
                    }
                    .tint(Theme.twitterBlue)
                }
            }
        }
    }
}
