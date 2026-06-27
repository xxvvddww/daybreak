import SwiftUI

/// One series on the super growth chart.
struct GrowthLine: Identifiable {
    let label: String
    let color: Color
    let series: [Double]
    let isYou: Bool
    var id: String { label }
}

/// A multi-line line chart of projected super balances over the career.
/// Ported from the prototype's `GrowthChart` SVG (300×170 space).
struct GrowthChartView: View {
    @Environment(\.theme) private var theme
    let lines: [GrowthLine]
    let years: Int

    var body: some View {
        Canvas { context, size in
            let scale = size.width / 300
            context.scaleBy(x: scale, y: scale)

            let W = 300.0, H = 170.0, padL = 4.0, padR = 6.0, padT = 12.0, padB = 20.0
            let maxY = max(1, lines.map { $0.series.last ?? 0 }.max() ?? 1)
            let span = max(1, years)
            func x(_ value: Double) -> Double { padL + (value / Double(span)) * (W - padL - padR) }
            func y(_ value: Double) -> Double { H - padB - (value / maxY) * (H - padT - padB) }

            for gridline in [0.0, 0.25, 0.5, 0.75, 1.0] {
                var path = Path()
                path.move(to: CGPoint(x: padL, y: y(maxY * gridline)))
                path.addLine(to: CGPoint(x: W - padR, y: y(maxY * gridline)))
                context.stroke(path, with: .color(theme.grid), lineWidth: 1)
            }

            var maxLabel = context.resolve(
                Text(DaybreakFormat.big(maxY)).font(.system(size: 9.5, design: .monospaced)))
            maxLabel.shading = .color(theme.ink3)
            context.draw(maxLabel, at: CGPoint(x: padL, y: y(maxY) - 4), anchor: .bottomLeading)

            for line in lines {
                var path = Path()
                for (t, value) in line.series.enumerated() {
                    let p = CGPoint(x: x(Double(t)), y: y(value))
                    if t == 0 { path.move(to: p) } else { path.addLine(to: p) }
                }
                context.stroke(
                    path,
                    with: .color(line.color.opacity(line.isYou ? 1 : 0.9)),
                    style: StrokeStyle(lineWidth: line.isYou ? 3 : 1.75, lineCap: .round, lineJoin: .round)
                )
            }

            var now = context.resolve(Text("now").font(.system(size: 9.5)))
            now.shading = .color(theme.ink3)
            context.draw(now, at: CGPoint(x: padL, y: H - 5), anchor: .bottomLeading)
            var end = context.resolve(Text("\(years)y").font(.system(size: 9.5)))
            end.shading = .color(theme.ink3)
            context.draw(end, at: CGPoint(x: W - padR, y: H - 5), anchor: .bottomTrailing)
        }
        .aspectRatio(300.0 / 170.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }
}
