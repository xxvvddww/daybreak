import SwiftUI

/// The Daybreak logo mark: a rising sun over a horizon, on a dark disc.
/// Drawn with `Canvas` from the prototype's SVG (36×36 grid).
struct MarkLogo: View {
    var size: CGFloat = 36

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 36
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * scale, y: y * scale) }
            let gold = Brand.gold

            // Disc
            let discRect = CGRect(x: 1 * scale, y: 1 * scale, width: 34 * scale, height: 34 * scale)
            context.fill(Path(ellipseIn: discRect), with: .color(Color(hex: "221E17")))
            context.stroke(Path(ellipseIn: discRect),
                           with: .color(Brand.paper.opacity(0.12)), lineWidth: 1 * scale)

            // Horizon line
            var horizon = Path()
            horizon.move(to: p(8, 23)); horizon.addLine(to: p(28, 23))
            context.stroke(horizon, with: .color(gold),
                           style: StrokeStyle(lineWidth: 1.5 * scale, lineCap: .round))

            // Half-sun above the horizon
            var dome = Path()
            dome.move(to: p(12, 23))
            dome.addCurve(to: p(24, 23), control1: p(12, 19.7), control2: p(20.3, 19.7))
            dome.closeSubpath()
            context.fill(dome, with: .color(gold))

            // Rays
            let rays: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (18, 9, 18, 12),
                (11.2, 12.6, 13, 14.1),
                (24.8, 12.6, 23, 14.1),
            ]
            for ray in rays {
                var path = Path()
                path.move(to: p(ray.0, ray.1)); path.addLine(to: p(ray.2, ray.3))
                context.stroke(path, with: .color(gold),
                               style: StrokeStyle(lineWidth: 1.5 * scale, lineCap: .round))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
