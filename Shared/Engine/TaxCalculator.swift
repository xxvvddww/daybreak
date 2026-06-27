import Foundation

/// Pure income-tax maths. Mirrors `prog()`, the Medicare-levy rule and the
/// marginal-rate loop from the prototype.
struct TaxCalculator: Sendable {
    let config: CountryConfig

    init(config: CountryConfig = .australia) {
        self.config = config
    }

    /// Progressive income tax on `taxable`, excluding the Medicare levy.
    func incomeTax(taxable: Double) -> Double {
        var tax = 0.0
        var lower = 0.0
        for bracket in config.brackets {
            if taxable > lower {
                tax += (min(taxable, bracket.upTo) - lower) * bracket.rate
                lower = bracket.upTo
            } else {
                break
            }
        }
        return tax
    }

    /// The Medicare levy, charged only when enabled and above the threshold.
    func medicareLevy(taxable: Double, enabled: Bool) -> Double {
        (enabled && taxable > config.medicareLevyThreshold)
            ? taxable * config.medicareLevyRate
            : 0
    }

    /// The user's top marginal rate (including the Medicare levy where it
    /// applies), as a whole-number percentage. Mirrors `marginalRate`.
    func marginalRatePercent(taxable: Double, medicare: Bool) -> Int {
        var rate = 0.0
        var lower = 0.0
        for bracket in config.brackets {
            if taxable > lower { rate = bracket.rate }
            lower = bracket.upTo
        }
        let levy = (medicare && taxable > config.medicareLevyThreshold)
            ? config.medicareLevyRate
            : 0
        return Int(((rate + levy) * 100).rounded())
    }
}
