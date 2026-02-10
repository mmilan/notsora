import SwiftUI

struct OverallProgressBar: View {
    let viewModel: CompressionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Overall Progress")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(viewModel.completedCount) / \(viewModel.jobs.count) completed")
                    .foregroundStyle(Theme.textSecondary)
            }

            ProgressView(value: viewModel.overallProgress)
                .progressViewStyle(.linear)
                .tint(Theme.twitterBlue)

            HStack {
                Text("\(Int(viewModel.overallProgress * 100))%")
                    .monospacedDigit()
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                if viewModel.failedCount > 0 {
                    Text("\(viewModel.failedCount) failed")
                        .foregroundStyle(Theme.error)
                }
            }
            .font(.caption)
        }
    }
}
