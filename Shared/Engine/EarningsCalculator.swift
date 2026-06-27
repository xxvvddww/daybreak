import Foundation

/// The time-independent breakdown of a salary: pay structure, schedule and the
/// per-second/per-day rates the rest of the app builds on. Mirrors the derived
/// values computed at the top of the prototype's `App()`.
struct EarningsBreakdown: Equatable, Sendable {
    // Pay structure
    var base: Double            // taxable income
    var superAmount: Double     // employer super for the year
    var superRate: Double       // contribution rate as a fraction
    var tax: Double             // income tax + Medicare levy
    var incomeTaxOnly: Double   // income tax excluding the levy
    var net: Double             // take-home (base − tax)
    var levy: Double            // Medicare levy
    var effectiveRate: Double   // tax ÷ base, clamped to [0, 0.99]
    var marginalRatePercent: Int

    // Schedule
    var spanHours: Double       // clock-in to clock-out, including breaks
    var paidHours: Double       // paid hours per working day
    var weeklyHours: Double
    var daysPerYear: Int
    var startSeconds: Double     // start-of-day, seconds since midnight
    var spanSeconds: Double
    var paidSeconds: Double

    // Rates
    var grossPerDay: Double
    var grossPerSecond: Double
    var freedomSeconds: Double   // the moment each day you stop working for the ATO
}

/// A live, time-dependent snapshot: how much has been earned so far "today".
struct LiveEarnings: Equatable, Sendable {
    var fraction: Double         // [0, 1] through the working day
    var nowSeconds: Double       // current clock position, seconds since midnight
    var earnedGross: Double
    var earnedKeep: Double
    var earnedTax: Double
    var earnedSuper: Double
    var beforeFreedom: Bool
    var isRestDay: Bool
}

/// Computes pay breakdowns and live earnings from `ProfileInputs`.
struct EarningsCalculator: Sendable {
    let config: CountryConfig
    let tax: TaxCalculator

    init(config: CountryConfig = .australia) {
        self.config = config
        self.tax = TaxCalculator(config: config)
    }

    func breakdown(for input: ProfileInputs) -> EarningsBreakdown {
        let sRate = input.superRatePercent / 100

        let base: Double
        let superAmount: Double
        if input.salaryIncludesSuper {
            base = input.salary / (1 + sRate)
            superAmount = input.salary - base
        } else {
            base = input.salary
            superAmount = base * sRate
        }

        var spanHours = input.endHour - input.startHour
        if spanHours <= 0 { spanHours += 24 }
        spanHours = max(1, spanHours)

        let paidHours = max(0.5, spanHours - (input.hasBreak ? Double(input.breakMinutes) / 60 : 0))
        let weeklyHours = paidHours * Double(input.workDays.count)
        let spanSeconds = spanHours * 3600
        let paidSeconds = paidHours * 3600
        let startSeconds = input.startHour * 3600
        let daysPerYear = max(1, input.workDays.count) * 52

        let levy = tax.medicareLevy(taxable: base, enabled: input.medicareLevy)
        let incomeTaxOnly = tax.incomeTax(taxable: base)
        let totalTax = incomeTaxOnly + levy
        let net = base - totalTax
        let effectiveRate = base > 0 ? min(0.99, max(0, totalTax / base)) : 0
        let marginal = tax.marginalRatePercent(taxable: base, medicare: input.medicareLevy)

        let grossPerDay = base / Double(daysPerYear)
        let grossPerSecond = base / (Double(daysPerYear) * paidSeconds)
        let freedomSeconds = startSeconds + effectiveRate * spanSeconds

        return EarningsBreakdown(
            base: base,
            superAmount: superAmount,
            superRate: sRate,
            tax: totalTax,
            incomeTaxOnly: incomeTaxOnly,
            net: net,
            levy: levy,
            effectiveRate: effectiveRate,
            marginalRatePercent: marginal,
            spanHours: spanHours,
            paidHours: paidHours,
            weeklyHours: weeklyHours,
            daysPerYear: daysPerYear,
            startSeconds: startSeconds,
            spanSeconds: spanSeconds,
            paidSeconds: paidSeconds,
            grossPerDay: grossPerDay,
            grossPerSecond: grossPerSecond,
            freedomSeconds: freedomSeconds
        )
    }

    /// Live earnings for a given fraction of the working day. On a rest day the
    /// fraction is forced to zero (nothing earned or taxed).
    func live(
        breakdown b: EarningsBreakdown,
        fraction rawFraction: Double,
        isRestDay: Bool
    ) -> LiveEarnings {
        let f = isRestDay ? 0 : rawFraction
        let nowSeconds = b.startSeconds + f * b.spanSeconds
        let earnedGross = b.grossPerDay * f
        let earnedKeep = earnedGross * (1 - b.effectiveRate)
        let earnedTax = earnedGross * b.effectiveRate
        let earnedSuper = (b.superAmount / Double(b.daysPerYear)) * f
        return LiveEarnings(
            fraction: f,
            nowSeconds: nowSeconds,
            earnedGross: earnedGross,
            earnedKeep: earnedKeep,
            earnedTax: earnedTax,
            earnedSuper: earnedSuper,
            beforeFreedom: f < b.effectiveRate,
            isRestDay: isRestDay
        )
    }
}
