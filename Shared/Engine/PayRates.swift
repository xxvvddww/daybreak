import Foundation

/// A single row in the Pay tab's rate table.
struct PayRate: Equatable, Sendable, Identifiable {
    var label: String
    var value: Double
    var emphasized: Bool
    var id: String { label }
}

/// Builds the per-second … per-year rate table. Mirrors the `rows` array in the
/// prototype's Pay tab, for both "on the clock" and "around the clock" bases.
struct PayRates: Sendable {
    func rates(
        amount: Double,
        breakdown b: EarningsBreakdown,
        inputs: ProfileInputs,
        aroundTheClock: Bool
    ) -> [PayRate] {
        let perSecond: Double
        let perDay: Double
        let perWeek: Double
        let perFortnight: Double

        if aroundTheClock {
            perSecond = amount / (365 * 24 * 3600)
            perDay = amount / 365
            perWeek = amount / 52
            perFortnight = amount / 26
        } else {
            perSecond = amount / (Double(b.daysPerYear) * b.paidSeconds)
            perDay = amount / Double(b.daysPerYear)
            perWeek = perDay * Double(inputs.workDays.count)
            perFortnight = perWeek * 2
        }

        return [
            PayRate(label: "Per second", value: perSecond, emphasized: true),
            PayRate(label: "Per minute", value: perSecond * 60, emphasized: false),
            PayRate(label: "Per hour", value: perSecond * 3600, emphasized: true),
            PayRate(label: "Per day", value: perDay, emphasized: false),
            PayRate(label: "Per week", value: perWeek, emphasized: false),
            PayRate(label: "Per fortnight", value: perFortnight, emphasized: false),
            PayRate(label: "Per month", value: amount / 12, emphasized: false),
            PayRate(label: "Per year", value: amount, emphasized: false),
        ]
    }
}
