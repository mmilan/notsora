import SwiftUI

struct VideoListSidebar: View {
    @Bindable var viewModel: VideoListViewModel

    var body: some View {
        List(viewModel.videos, selection: $viewModel.selectedVideoID) { video in
            VideoRowView(video: video)
                .tag(video.id)
                .contextMenu {
                    Button("Remove", role: .destructive) {
                        viewModel.removeVideo(video)
                    }
                }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .overlay {
            if viewModel.videos.isEmpty {
                ContentUnavailableView {
                    Label("No Videos", systemImage: "film")
                        .foregroundStyle(Theme.twitterBlue)
                } description: {
                    Text("Drag and drop video files here or click Add Files in the toolbar.")
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .overlay {
            if viewModel.isProbing {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                            .tint(Theme.twitterBlue)
                        Text("Analyzing videos…")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(8)
                    .background(Theme.cardBackground, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.border, lineWidth: 1)
                    )
                    .padding(.bottom, 8)
                }
            }
        }
    }
}
