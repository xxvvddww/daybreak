import SwiftUI

/// The six primary destinations. Modelled as an enum so the tab bar, routing
/// and accessibility all share one source of truth.
enum AppTab: String, CaseIterable, Identifiable {
    case today, pay, superannuation, damage, stats, setup

    var id: String { rawValue }

    var label: String {
        switch self {
        case .today: "Today"
        case .pay: "Pay"
        case .superannuation: "Super"
        case .damage: "Damage"
        case .stats: "Stats"
        case .setup: "Setup"
        }
    }

    var systemImage: String {
        switch self {
        case .today: "sun.max"
        case .pay: "creditcard"
        case .superannuation: "checkmark.shield"
        case .damage: "drop.fill"
        case .stats: "chart.bar"
        case .setup: "slider.horizontal.3"
        }
    }

    /// Damage gets the tax accent; everything else uses keep.
    var usesTaxAccent: Bool { self == .damage }
}
