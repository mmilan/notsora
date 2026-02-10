import SwiftUI

struct LabeledSlider: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var step: Int = 1
    var valueLabel: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(valueLabel ?? "\(value)")
                    .foregroundStyle(Theme.textSecondary)
                    .monospacedDigit()
            }
            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: Double(step)
            )
            .tint(Theme.twitterBlue)
        }
    }
}
