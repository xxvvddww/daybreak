import SwiftUI

/// The income-distribution bar on the Stats screen: a filled track with
/// percentile ticks and a "You" marker. Ported from the prototype's Stats bar.
struct PercentileBarView: View {
    @Environment(\.theme) private var theme
    let percentile: Double
    let lowAnchorLabel: String
    let highAnchorLabel: String

    private let ticks: [(label: String, value: Double)] = [
        ("p25", 25), ("Median", 50), ("p75", 75), ("p90", 90),
    ]

    var body: some View {
        let clamped = min(98, max(2, percentile))

        VStack(spacing: 0) {
            GeometryReader { geo in
                let w = geo.size.width
                let barY = 24.0
                ZStack(alignment: .topLeading) {
                    Capsule()
                        .fill(theme.surface2)
                        .frame(width: w, height: 10)
                        .position(x: w / 2, y: barY)
                    Capsule()
                        .fill(theme.keep)
                        .frame(width: w * clamped / 100, height: 10)
                        .position(x: (w * clamped / 100) / 2, y: barY)
                    ForEach(ticks, id: \.label) { tick in
                        Rectangle()
                            .fill(theme.hairline)
                            .frame(width: 1.5, height: 16)
                            .position(x: w * tick.value / 100, y: barY)
                    }
                    Circle()
                        .fill(theme.surface)
                        .overlay(Circle().strokeBorder(theme.keep, lineWidth: 3))
                        .frame(width: 18, height: 18)
                        .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
                        .position(x: w * clamped / 100, y: barY)
                    Text("You")
                        .sans(11, weight: .bold)
                        .foregroundStyle(theme.keep)
                        .fixedSize()
                        .dynamicTypeSize(...DynamicTypeSize.large)
                        .position(x: w * clamped / 100, y: 4)
                }
            }
            .frame(height: 38)

            GeometryReader { geo in
                let w = geo.size.width
                ForEach(ticks, id: \.label) { tick in
                    Text(tick.label)
                        .sans(10)
                        .foregroundStyle(theme.ink3)
                        .fixedSize()
                        // Cap growth so the absolutely-positioned ticks don't collide.
                        .dynamicTypeSize(...DynamicTypeSize.large)
                        .position(x: w * tick.value / 100, y: 8)
                }
            }
            .frame(height: 16)

            HStack {
                Text(lowAnchorLabel)
                Spacer()
                Text(highAnchorLabel)
            }
            .mono(11)
            .foregroundStyle(theme.ink3)
            .padding(.top, 8)
        }
        .padding(.horizontal, 18)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .glassCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Income percentile")
        .accessibilityValue("Higher than \(Int(percentile.rounded())) percent of earners")
    }
}
