import SwiftUI

/// The user's appearance choice. Defaults to following the system.
enum ThemePreference: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    /// The `ColorScheme` to force, or `nil` to follow the system.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    /// Resolves to a concrete scheme given the current environment scheme.
    func resolvedScheme(system: ColorScheme) -> ColorScheme {
        colorScheme ?? system
    }
}
