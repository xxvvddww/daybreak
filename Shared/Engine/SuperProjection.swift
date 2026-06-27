import Foundation

/// The result of modelling a salary-sacrifice amount. Mirrors the `model()`
/// closure in the prototype's Super tab.
struct SuperModelResult: Equatable, Sendable, Identifiable {
    var perPay: Double
    var grossExtra: Double      // extra contributed across the year, before cap
    var cappedExtra: Double     // extra after applying the concessional cap
    var over: Bool              // would the user exceed the cap?
    var annualNet: Double       // what actually lands in super each year, post tax
    var balance: Double         // projected balance after `years`

    var id: Double { perPay }
}

/// Future-value / compounding maths for superannuation projections.
struct SuperProjection: Sendable {
    let config: CountryConfig

    init(config: CountryConfig = .australia) {
        self.config = config
    }

    /// Future-value annuity factor for `years` equal annual contributions at
    /// rate `r`. Mirrors `fvFactor`.
    func fvFactor(rate r: Double, years n: Int) -> Double {
        r == 0 ? Double(n) : (pow(1 + r, Double(n)) - 1) / r
    }

    func model(
        perPay: Double,
        employerGross: Double,
        growthRate r: Double,
        payFrequency: PayFrequency,
        years: Int
    ) -> SuperModelResult {
        let paysPerYear = Double(payFrequency.periodsPerYear)
        let capRoom = max(0, config.concessionalCap - employerGross)
        let grossExtra = perPay * paysPerYear
        let cappedExtra = min(grossExtra, capRoom)
        let over = grossExtra > capRoom + 0.5
        let annualNet = (employerGross + cappedExtra) * (1 - config.contributionsTaxRate)
        let balance = annualNet * fvFactor(rate: r, years: years)
        return SuperModelResult(
            perPay: perPay,
            grossExtra: grossExtra,
            cappedExtra: cappedExtra,
            over: over,
            annualNet: annualNet,
            balance: balance
        )
    }

    /// Year-by-year balance series (index 0 = now … index `years`).
    func series(annualNet: Double, growthRate r: Double, years: Int) -> [Double] {
        (0...max(0, years)).map { annualNet * fvFactor(rate: r, years: $0) }
    }
}
