import SwiftUI

/// Fixed brand colours used by logos, the live "sun" mark, onboarding and the
/// widget wallpaper — independent of the in-app light/dark theme. Ported from
/// the prototype's `C` palette. Lives in `Shared/` so the widget can use it.
enum Brand {
    static let keep = Color(hex: "3D6B57")
    static let keepBright = Color(hex: "4E8A6B")
    static let tax = Color(hex: "A8552F")
    static let taxBright = Color(hex: "C26A3F")
    static let gold = Color(hex: "B2854A")
    static let paper = Color(hex: "F3EFE6")
    static let ink = Color(hex: "1A1814")
    static let muted = Color(hex: "8C8473")

    /// The warm, editorial wallpaper behind the home / lock-screen widget.
    static func wallpaper(dark: Bool) -> LinearGradient {
        let stops: [Gradient.Stop] = dark
            ? [
                .init(color: Color(hex: "13121A"), location: 0.0),
                .init(color: Color(hex: "241F28"), location: 0.38),
                .init(color: Color(hex: "3A2C2F"), location: 0.70),
                .init(color: Color(hex: "523B30"), location: 1.0),
            ]
            : [
                .init(color: Color(hex: "413C48"), location: 0.0),
                .init(color: Color(hex: "6C5A5A"), location: 0.36),
                .init(color: Color(hex: "A67F6B"), location: 0.66),
                .init(color: Color(hex: "D9B991"), location: 1.0),
            ]
        return LinearGradient(
            gradient: Gradient(stops: stops),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
