import SwiftUI

/// The translucent "quiet luxury" card surface used throughout the app.
///
/// On iOS 26+ (built with Xcode 26+) this is real Liquid Glass; on earlier
/// systems it falls back to the hand-tuned gradient glass so the app looks
/// intentional everywhere. The `#if compiler` guard keeps the file compiling
/// on older toolchains that don't know the Liquid Glass APIs.
struct GlassCardModifier: ViewModifier {
    @Environment(\.theme) private var theme
    var cornerRadius: CGFloat = 18

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            content
                // Clip so full-bleed rows and dividers respect the rounded corners.
                .clipShape(shape)
                .glassEffect(.regular, in: shape)
        } else {
            legacy(content)
        }
        #else
        legacy(content)
        #endif
    }

    private func legacy(_ content: Content) -> some View {
        content
            .background(shape.fill(theme.glassFill))
            .clipShape(shape)
            .overlay(shape.strokeBorder(theme.glassBorder, lineWidth: 1))
            .shadow(color: theme.glassShadow, radius: 16, x: 0, y: 12)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 18) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}
