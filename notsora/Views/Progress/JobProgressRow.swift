import SwiftUI

struct JobProgressRow: View {
    let job: CompressionJob

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(job.videoFile.filename)
                    .fontWeight(.medium)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                statusBadge
            }

            if job.status == .running {
                ProgressView(value: job.progress)
                    .tint(Theme.twitterBlue)

                HStack {
                    Text("\(Int(job.progress * 100))%")
                        .monospacedDigit()
                        .foregroundStyle(Theme.textPrimary)

                    Spacer()

                    if let eta = job.etaFormatted {
                        Text(eta)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .font(.caption)
            }

            if job.status == .completed {
                HStack {
                    if let size = job.outputFileSizeFormatted {
                        Label(size, systemImage: "doc.fill")
                    }
                    if let elapsed = job.elapsedFormatted {
                        Label(elapsed, systemImage: "clock")
                    }
                }
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            }

            if job.status == .failed, let error = job.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Theme.error)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusBadge: some View {
        Text(job.status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(badgeColor.opacity(0.15))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch job.status {
        case .pending: return Theme.textSecondary
        case .running: return Theme.twitterBlue
        case .completed: return Theme.success
        case .failed: return Theme.error
        case .cancelled: return Theme.warning
        }
    }
}
