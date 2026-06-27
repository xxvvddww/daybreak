import SwiftUI

/// The translucent "quiet luxury" card surface used throughout the app:
/// a soft gradient fill, a hairline border and a low drop shadow.
struct GlassCardModifier: ViewModifier {
    @Environment(\.theme) private var theme
    var cornerRadius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(theme.glassFill)
            )
            // Clip so full-bleed rows and dividers respect the rounded corners.
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(theme.glassBorder, lineWidth: 1)
            )
            .shadow(color: theme.glassShadow, radius: 16, x: 0, y: 12)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 18) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}
