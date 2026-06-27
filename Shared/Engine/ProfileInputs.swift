import Foundation

/// The complete set of user inputs the engine needs to compute every figure in
/// the app. This is a plain, `Codable` value type — deliberately free of
/// SwiftData and SwiftUI — so it can be:
///
/// - consumed by the pure calculators (and unit-tested in isolation),
/// - persisted as a SwiftData `Profile` in the app, and
/// - serialised into the shared App Group snapshot the widget reads.
///
/// Days are indexed Monday = 0 … Sunday = 6, matching the original prototype.
/// Hours are "hours since midnight" and may be fractional (e.g. 9.5 = 9:30am).
struct ProfileInputs: Codable, Equatable, Sendable {
    var salary: Double
    var startHour: Double
    var endHour: Double
    var workDays: [Int]
    var hasBreak: Bool
    var breakMinutes: Int
    var payFrequency: PayFrequency
    var medicareLevy: Bool
    var salaryIncludesSuper: Bool
    var superRatePercent: Double

    init(
        salary: Double = 95_000,
        startHour: Double = 9,
        endHour: Double = 17,
        workDays: [Int] = [0, 1, 2, 3, 4],
        hasBreak: Bool = true,
        breakMinutes: Int = 30,
        payFrequency: PayFrequency = .fortnightly,
        medicareLevy: Bool = true,
        salaryIncludesSuper: Bool = false,
        superRatePercent: Double = 12
    ) {
        self.salary = salary
        self.startHour = startHour
        self.endHour = endHour
        self.workDays = workDays
        self.hasBreak = hasBreak
        self.breakMinutes = breakMinutes
        self.payFrequency = payFrequency
        self.medicareLevy = medicareLevy
        self.salaryIncludesSuper = salaryIncludesSuper
        self.superRatePercent = superRatePercent
    }
}
