import SwiftUI

/// The radiant "sun" mark used across the app, drawn with `Canvas` from the
/// prototype's SVG (a filled core plus eight rays on a 24×24 grid).
struct SunIcon: View {
    var size: CGFloat = 26
    var color: Color

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 24
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

            let coreRadius = 4.4 * scale
            let coreRect = CGRect(
                x: center.x - coreRadius, y: center.y - coreRadius,
                width: coreRadius * 2, height: coreRadius * 2
            )
            context.fill(Path(ellipseIn: coreRect), with: .color(color))

            for i in 0..<8 {
                let angle = Double(i) * .pi / 4
                var ray = Path()
                ray.move(to: CGPoint(
                    x: center.x + cos(angle) * 7 * scale,
                    y: center.y + sin(angle) * 7 * scale
                ))
                ray.addLine(to: CGPoint(
                    x: center.x + cos(angle) * 9.4 * scale,
                    y: center.y + sin(angle) * 9.4 * scale
                ))
                context.stroke(ray, with: .color(color),
                               style: StrokeStyle(lineWidth: 1.6 * scale, lineCap: .round))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
