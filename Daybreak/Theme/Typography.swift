import SwiftUI

/// Applies a system font at a specific point size that still scales with the
/// user's Dynamic Type setting (via `@ScaledMetric`), so the editorial layout
/// keeps its proportions while remaining accessible.
private struct ScaledFontModifier: ViewModifier {
    @ScaledMetric private var size: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design

    init(size: CGFloat, weight: Font.Weight, design: Font.Design, relativeTo textStyle: Font.TextStyle) {
        _size = ScaledMetric(wrappedValue: size, relativeTo: textStyle)
        self.weight = weight
        self.design = design
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }
}

extension View {
    /// Editorial serif (New York) — display headings and pull quotes.
    func serif(_ size: CGFloat, weight: Font.Weight = .medium, relativeTo: Font.TextStyle = .title) -> some View {
        modifier(ScaledFontModifier(size: size, weight: weight, design: .serif, relativeTo: relativeTo))
    }

    /// Grotesque sans (SF) — the workhorse UI font.
    func sans(_ size: CGFloat, weight: Font.Weight = .regular, relativeTo: Font.TextStyle = .body) -> some View {
        modifier(ScaledFontModifier(size: size, weight: weight, design: .default, relativeTo: relativeTo))
    }

    /// Monospaced (SF Mono) — figures and tabular numbers.
    func mono(_ size: CGFloat, weight: Font.Weight = .medium, relativeTo: Font.TextStyle = .body) -> some View {
        modifier(ScaledFontModifier(size: size, weight: weight, design: .monospaced, relativeTo: relativeTo))
    }
}
