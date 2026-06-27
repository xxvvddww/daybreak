import SwiftUI

/// A labelled figure with a coloured dot, in a glass card. Used in grids on the
/// Today screen.
struct StatBox: View {
    @Environment(\.theme) private var theme
    let label: String
    let value: String
    let dot: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) {
                Circle()
                    .fill(dot)
                    .frame(width: 7, height: 7)
                Text(label)
                    .sans(12.5, weight: .semibold)
                    .foregroundStyle(theme.ink2)
            }
            Text(value)
                .mono(22, weight: .semibold)
                .foregroundStyle(theme.ink)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 15)
        .padding(.horizontal, 16)
        .glassCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }
}
