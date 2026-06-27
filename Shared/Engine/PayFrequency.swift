import Foundation

/// How often the user is paid. `periodsPerYear` mirrors the `PAYS` table.
enum PayFrequency: String, CaseIterable, Codable, Sendable, Identifiable {
    case weekly
    case fortnightly
    case monthly

    var id: String { rawValue }

    var periodsPerYear: Int {
        switch self {
        case .weekly: 52
        case .fortnightly: 26
        case .monthly: 12
        }
    }

    var label: String {
        switch self {
        case .weekly: "Weekly"
        case .fortnightly: "Fortnightly"
        case .monthly: "Monthly"
        }
    }
}
