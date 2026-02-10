import SwiftUI

struct ProgressPanel: View {
    @Bindable var viewModel: CompressionViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Compression Progress")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                if viewModel.isCompressing {
                    Button("Cancel All", role: .destructive) {
                        viewModel.cancelAll()
                    }
                    .tint(Theme.error)
                } else {
                    Button("Done") {
                        viewModel.dismissProgress()
                    }
                    .keyboardShortcut(.defaultAction)
                    .tint(Theme.twitterBlue)
                }
            }

            OverallProgressBar(viewModel: viewModel)

            Divider()
                .background(Theme.border)

            // Per-job list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.jobs) { job in
                        JobProgressRow(job: job)
                        if job.id != viewModel.jobs.last?.id {
                            Divider()
                                .background(Theme.border)
                        }
                    }
                }
            }
            .frame(maxHeight: 400)
        }
        .padding(24)
        .background(Theme.background)
        .frame(minWidth: 500, minHeight: 300)
    }
}
