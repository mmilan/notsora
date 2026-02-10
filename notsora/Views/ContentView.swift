import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State var videoList = VideoListViewModel()
    @State var compression = CompressionViewModel()
    @State private var showMissingBinaryAlert = false
    @State private var missingBinaryMessage = ""

    var body: some View {
        NavigationSplitView {
            VideoListSidebar(viewModel: videoList)
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            if let video = videoList.selectedVideo {
                VideoDetailView(video: video, viewModel: videoList)
            } else {
                ContentUnavailableView {
                    Label("No Selection", systemImage: "sidebar.left")
                        .foregroundStyle(Theme.textSecondary)
                } description: {
                    Text("Select a video from the sidebar to view and edit its settings.")
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .navigationTitle("notsora")
        .tint(Theme.twitterBlue)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    videoList.showOpenPanel()
                } label: {
                    Label("Add Files", systemImage: "plus")
                }
                .keyboardShortcut("o", modifiers: .command)

                Button {
                    videoList.showOutputDirectoryPicker()
                } label: {
                    Label("Output Folder", systemImage: "folder")
                }

                Button {
                    compression.startCompression(videoList: videoList)
                } label: {
                    Label("Compress All", systemImage: "arrow.down.circle.fill")
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(
                    videoList.videos.isEmpty ||
                    videoList.outputDirectory == nil ||
                    compression.isCompressing
                )
            }
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            handleDrop(providers: providers)
            return true
        }
        .sheet(isPresented: $compression.showProgressSheet) {
            ProgressPanel(viewModel: compression)
        }
        .alert("Missing FFmpeg", isPresented: $showMissingBinaryAlert) {
            Button("OK") {}
        } message: {
            Text(missingBinaryMessage)
        }
        .onAppear {
            checkBinaries()
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        var urls: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                defer { group.leave() }
                if let data = item as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    urls.append(url)
                }
            }
        }

        group.notify(queue: .main) {
            Task {
                await videoList.addFiles(urls: urls)
            }
        }
    }

    private func checkBinaries() {
        let check = FFmpegRunner.checkBinariesExist()
        var missing: [String] = []
        if !check.ffmpeg { missing.append("ffmpeg") }
        if !check.ffprobe { missing.append("ffprobe") }

        if !missing.isEmpty {
            missingBinaryMessage = "The following binaries were not found in the app bundle: \(missing.joined(separator: ", ")). Please add them to the Resources folder."
            showMissingBinaryAlert = true
        }
    }
}
