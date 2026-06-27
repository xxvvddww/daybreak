import SwiftUI

/// The horizontal "day bar": a track split into a tax portion and a keep
/// portion, with a marker showing how far through the day you are.
/// `glass` switches to the light-on-wallpaper palette used by the widget card.
struct DayBarView: View {
    @Environment(\.theme) private var theme
    var fraction: Double
    var effectiveRate: Double
    var glass: Bool = false

    var body: some View {
        let split = min(max(effectiveRate, 0), 1)
        let progress = min(max(fraction, 0), 1)
        let track = glass ? Color.white.opacity(0.22) : theme.surface2
        let taxColor = glass ? Color(hex: "E89B72") : theme.tax
        let keepColor = glass ? Color.white.opacity(0.88) : theme.keep

        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(track).frame(height: 5)
                HStack(spacing: 0) {
                    Rectangle().fill(taxColor).frame(width: width * split)
                    Rectangle().fill(keepColor)
                }
                .frame(height: 5)
                .clipShape(Capsule())

                Circle()
                    .fill(Color.white)
                    .frame(width: 13, height: 13)
                    .overlay(Circle().strokeBorder(Color.black.opacity(0.05), lineWidth: 2))
                    .shadow(color: .black.opacity(0.4), radius: 2, y: 1)
                    .offset(x: width * progress - 6.5)
            }
            .frame(height: geo.size.height, alignment: .center)
        }
        .frame(height: 14)
        .accessibilityHidden(true)
    }
}
