import Foundation

/// The "damage" figures: how much tax costs, framed in days, time and things.
/// Mirrors the calculations at the top of the prototype's Damage tab.
struct DamageReport: Equatable, Sendable {
    var cents: Int               // cents of every dollar lost to tax
    var daysForGovernment: Int   // working days a year before you earn for yourself
    var dailyTaxSeconds: Double   // seconds of each working day handed over
    var lifetimeTax: Double       // tax over a full career, today's salary
    var coffees: Int
    var rentMonths: Double
    var taxFreedomDay: Date       // the date you stop working for the ATO
}

struct DamageCalculator: Sendable {
    let config: CountryConfig

    init(config: CountryConfig = .australia) {
        self.config = config
    }

    func report(breakdown b: EarningsBreakdown, now: Date, calendar: Calendar = .current) -> DamageReport {
        let cents = Int((b.effectiveRate * 100).rounded())
        let daysForGovernment = Int((b.effectiveRate * Double(b.daysPerYear)).rounded())
        let dailyTaxSeconds = b.effectiveRate * b.paidHours * 3600
        let lifetimeTax = b.tax * Double(config.careerYears)
        let coffees = Int((b.tax / config.coffeePrice).rounded())
        let rentMonths = b.tax / config.monthlyRent

        let year = calendar.component(.year, from: now)
        let jan1 = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? now
        let dayOfFreedom = Int((b.effectiveRate * 365).rounded())
        let taxFreedomDay = calendar.date(byAdding: .day, value: dayOfFreedom, to: jan1) ?? jan1

        return DamageReport(
            cents: cents,
            daysForGovernment: daysForGovernment,
            dailyTaxSeconds: dailyTaxSeconds,
            lifetimeTax: lifetimeTax,
            coffees: coffees,
            rentMonths: rentMonths,
            taxFreedomDay: taxFreedomDay
        )
    }
}
