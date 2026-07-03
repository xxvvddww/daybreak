import SwiftUI

/// The full set of semantic colours for one appearance, ported verbatim from
/// the prototype's `VARS` map. Injected through the environment so views read
/// `theme.ink` rather than hard-coding hex values.
struct Theme: Sendable {
    // Backgrounds
    let background: Color
    let surface: Color
    let surface2: Color

    // Ink (text)
    let ink: Color
    let ink2: Color
    let ink3: Color
    let hairline: Color

    // Accents
    let keep: Color
    let keepSoft: Color
    let tax: Color
    let taxSoft: Color
    let gold: Color

    // Segmented control
    let seg: Color
    let segOn: Color

    // Inverted "summary" card
    let summary: Color
    let summaryText: Color
    let summaryMuted: Color
    let summaryLine: Color

    // Chips
    let chip: Color
    let chipText: Color

    // Misc
    let grid: Color
    let toggleOff: Color
    let indicator: Color
    let tabOff: Color
    let tabBar: Color

    // Glass surfaces
    let glassTop: Color
    let glassBottom: Color
    let glassBorder: Color
    let glassShadow: Color

    /// The translucent gradient used as the fill of glass cards.
    var glassFill: LinearGradient {
        LinearGradient(colors: [glassTop, glassBottom], startPoint: .top, endPoint: .bottom)
    }
}

extension Theme {
    static let light = Theme(
        // Warm paper rather than clinical white — the quiet-luxury canvas.
        background: Color(hex: "FBFAF7"),
        surface: Color(hex: "F5F4F1"),
        surface2: Color(hex: "ECEAE4"),
        ink: Color(hex: "1A1814"),
        ink2: Color(hex: "6B6557"),
        ink3: Color(hex: "9C968A"),
        hairline: Color(hex: "E7E4DD"),
        keep: Color(hex: "2EAE50"),
        keepSoft: Color(hex: "E7F6EC"),
        tax: Color(hex: "A8552F"),
        taxSoft: Color(hex: "F7EBE3"),
        gold: Color(hex: "9C7636"),
        seg: Color(hex: "ECEAE4"),
        segOn: Color(hex: "FFFFFF"),
        summary: Color(hex: "1A1814"),
        summaryText: Color(hex: "F3EFE6"),
        summaryMuted: Color(hex: "F3EFE6").opacity(0.58),
        summaryLine: Color(hex: "34302A"),
        chip: Color(hex: "F0EDE6"),
        chipText: Color(hex: "7A4F2C"),
        grid: Color(hex: "ECEAE4"),
        toggleOff: Color(hex: "E2DFD8"),
        indicator: Color(hex: "1A1814").opacity(0.22),
        tabOff: Color(hex: "A39C8E"),
        tabBar: Color(hex: "FFFFFF").opacity(0.85),
        glassTop: Color(hex: "FFFFFF").opacity(0.94),
        glassBottom: Color(hex: "F5F4F1").opacity(0.76),
        glassBorder: Color.black.opacity(0.055),
        glassShadow: Color.black.opacity(0.10)
    )

    static let dark = Theme(
        background: Color(hex: "15130E"),
        surface: Color(hex: "201D16"),
        surface2: Color(hex: "2B271E"),
        ink: Color(hex: "F2EEE4"),
        ink2: Color(hex: "A69D8B"),
        ink3: Color(hex: "6E6655"),
        hairline: Color(hex: "322E24"),
        keep: Color(hex: "2EAE50"),
        keepSoft: Color(hex: "172620"),
        tax: Color(hex: "DA8259"),
        taxSoft: Color(hex: "2E1E16"),
        gold: Color(hex: "D3AC63"),
        seg: Color(hex: "14110C"),
        segOn: Color(hex: "322E24"),
        summary: Color(hex: "0D0B08"),
        summaryText: Color(hex: "F2EEE4"),
        summaryMuted: Color(hex: "F2EEE4").opacity(0.5),
        summaryLine: Color(hex: "2A261D"),
        chip: Color(hex: "2E1E16"),
        chipText: Color(hex: "E2A483"),
        grid: Color(hex: "2A261D"),
        toggleOff: Color(hex: "39342A"),
        indicator: Color(hex: "F2EEE4").opacity(0.26),
        tabOff: Color(hex: "6E6655"),
        tabBar: Color(hex: "100E0A").opacity(0.82),
        glassTop: Color(hex: "3C372C").opacity(0.72),
        glassBottom: Color(hex: "28241C").opacity(0.5),
        glassBorder: Color.white.opacity(0.09),
        glassShadow: Color.black.opacity(0.45)
    )

    static func resolved(for scheme: ColorScheme) -> Theme {
        scheme == .dark ? .dark : .light
    }
}

// MARK: - Environment

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .light
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
