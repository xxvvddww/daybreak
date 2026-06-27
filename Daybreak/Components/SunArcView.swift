import SwiftUI

/// The arched "sun over the day" visualization on the Today screen. The arc is
/// split into a tax portion and a keep portion; a dashed marker shows the
/// freedom point and a glowing sun shows the current moment. Ported from the
/// prototype's `SunArc` SVG (300×172 space).
struct SunArcView: View {
    @Environment(\.theme) private var theme
    var fraction: Double
    var effectiveRate: Double

    var body: some View {
        Canvas { context, size in
            let scale = size.width / 300
            context.scaleBy(x: scale, y: scale)

            let cx = 150.0, cy = 148.0, radius = 120.0
            func point(_ t: Double) -> CGPoint {
                let angle = Double.pi * (1 - t)
                return CGPoint(x: cx + radius * cos(angle), y: cy - radius * sin(angle))
            }
            func arc(from: Double, to: Double) -> Path {
                var path = Path()
                let steps = 60
                for i in 0...steps {
                    let t = from + (to - from) * Double(i) / Double(steps)
                    let p = point(t)
                    if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
                }
                return path
            }

            let eff = min(max(effectiveRate, 0), 1)
            let f = min(max(fraction, 0.001), 0.999)
            let wide = StrokeStyle(lineWidth: 8, lineCap: .round)

            context.stroke(arc(from: 0, to: 1), with: .color(theme.surface2), style: wide)
            context.stroke(arc(from: 0, to: eff), with: .color(theme.tax), style: wide)
            context.stroke(arc(from: eff, to: 1), with: .color(theme.keep), style: wide)

            var baseline = Path()
            baseline.move(to: CGPoint(x: 24, y: 148))
            baseline.addLine(to: CGPoint(x: 276, y: 148))
            context.stroke(baseline, with: .color(theme.hairline), lineWidth: 1.5)

            let freedom = point(eff)
            var marker = Path()
            marker.move(to: freedom)
            marker.addLine(to: CGPoint(x: freedom.x, y: 148))
            context.stroke(marker, with: .color(theme.ink3),
                           style: StrokeStyle(lineWidth: 1.2, dash: [2, 3]))
            let freedomDot = CGRect(x: freedom.x - 3.5, y: freedom.y - 3.5, width: 7, height: 7)
            context.fill(Path(ellipseIn: freedomDot), with: .color(theme.surface))
            context.stroke(Path(ellipseIn: freedomDot), with: .color(theme.ink2), lineWidth: 1.5)

            let sun = point(f)
            context.fill(Path(ellipseIn: CGRect(x: sun.x - 15, y: sun.y - 15, width: 30, height: 30)),
                         with: .color(theme.gold.opacity(0.18)))
            context.fill(Path(ellipseIn: CGRect(x: sun.x - 7.5, y: sun.y - 7.5, width: 15, height: 15)),
                         with: .color(theme.gold))

            var start = context.resolve(Text("START").font(.system(size: 10.5, weight: .semibold)))
            start.shading = .color(theme.ink3)
            context.draw(start, at: CGPoint(x: 24, y: 164), anchor: .leading)
            var finish = context.resolve(Text("FINISH").font(.system(size: 10.5, weight: .semibold)))
            finish.shading = .color(theme.ink3)
            context.draw(finish, at: CGPoint(x: 276, y: 164), anchor: .trailing)
        }
        .aspectRatio(300.0 / 172.0, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }
}
