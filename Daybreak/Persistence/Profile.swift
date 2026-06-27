import Foundation
import SwiftData

/// The user's financial profile, persisted with SwiftData.
///
/// This is the single piece of genuinely *structured* persistent data in the
/// app, so it lives in SwiftData (per the project's constraints), while purely
/// cosmetic preferences (theme, onboarding) use `@AppStorage`. The app keeps a
/// single `Profile` record; ``ProfileStore`` fetches-or-creates it.
///
/// All maths is performed on the plain `ProfileInputs` value type, so this model
/// is a thin persistence shell that converts to and from it.
@Model
final class Profile {
    var salary: Double
    var startHour: Double
    var endHour: Double
    var workDays: [Int]
    var hasBreak: Bool
    var breakMinutes: Int
    var payFrequencyRaw: String
    var medicareLevy: Bool
    var salaryIncludesSuper: Bool
    var superRatePercent: Double
    var createdAt: Date

    init(inputs: ProfileInputs = ProfileInputs(), createdAt: Date = .now) {
        self.salary = inputs.salary
        self.startHour = inputs.startHour
        self.endHour = inputs.endHour
        self.workDays = inputs.workDays
        self.hasBreak = inputs.hasBreak
        self.breakMinutes = inputs.breakMinutes
        self.payFrequencyRaw = inputs.payFrequency.rawValue
        self.medicareLevy = inputs.medicareLevy
        self.salaryIncludesSuper = inputs.salaryIncludesSuper
        self.superRatePercent = inputs.superRatePercent
        self.createdAt = createdAt
    }

    /// Bridges the persisted model to/from the engine's value type.
    var inputs: ProfileInputs {
        get {
            ProfileInputs(
                salary: salary,
                startHour: startHour,
                endHour: endHour,
                workDays: workDays,
                hasBreak: hasBreak,
                breakMinutes: breakMinutes,
                payFrequency: PayFrequency(rawValue: payFrequencyRaw) ?? .fortnightly,
                medicareLevy: medicareLevy,
                salaryIncludesSuper: salaryIncludesSuper,
                superRatePercent: superRatePercent
            )
        }
        set {
            salary = newValue.salary
            startHour = newValue.startHour
            endHour = newValue.endHour
            workDays = newValue.workDays
            hasBreak = newValue.hasBreak
            breakMinutes = newValue.breakMinutes
            payFrequencyRaw = newValue.payFrequency.rawValue
            medicareLevy = newValue.medicareLevy
            salaryIncludesSuper = newValue.salaryIncludesSuper
            superRatePercent = newValue.superRatePercent
        }
    }
}
