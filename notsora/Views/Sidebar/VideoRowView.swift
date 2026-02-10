import SwiftUI

struct VideoRowView: View {
    let video: VideoFile

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(video.filename)
                .fontWeight(.medium)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .truncationMode(.middle)

            HStack(spacing: 8) {
                if video.duration > 0 {
                    Label(video.durationFormatted, systemImage: "clock")
                        .foregroundStyle(Theme.textSecondary)
                }

                if video.width > 0 {
                    Label(video.resolutionString, systemImage: "rectangle.on.rectangle")
                        .foregroundStyle(Theme.textSecondary)
                }

                Label(video.fileSizeFormatted, systemImage: "doc")
                    .foregroundStyle(Theme.textSecondary)
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Theme.border, lineWidth: 1)
        )
    }
}
