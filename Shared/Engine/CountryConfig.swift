import Foundation

/// Country-specific tax, super and cost-of-living configuration.
///
/// Mirrors the `CO`, `AU_BRACKETS`, `DIST_AU`, `AU_STATES`, `CONCESSIONAL_CAP`
/// and `CONTRIB_TAX` constants from the original Daybreak prototype
/// (Australian resident, 2025-26 — indicative only).
///
/// Keeping every jurisdiction-specific number in one value type means the rest
/// of the engine is country-agnostic and trivially testable, and a future
/// jurisdiction is a new `CountryConfig` rather than a code change.
struct CountryConfig: Sendable, Equatable {

    /// A progressive income-tax bracket. `upTo` is the inclusive upper bound of
    /// the bracket (`.infinity` for the top bracket).
    struct TaxBracket: Sendable, Equatable {
        let upTo: Double
        let rate: Double
    }

    /// A single anchor point on the income-distribution curve.
    struct DistributionAnchor: Sendable, Equatable {
        let percentile: Double
        let income: Double
    }

    /// A region's (state/territory) median personal income.
    struct RegionMedian: Sendable, Equatable, Identifiable {
        let code: String
        let median: Double
        var id: String { code }
    }

    let name: String
    let localeIdentifier: String
    let currencyCode: String
    /// Human name of the revenue authority, e.g. "the ATO".
    let revenueBody: String
    /// Upper bound of the salary slider.
    let maxSalary: Double
    let coffeePrice: Double
    let monthlyRent: Double
    let careerYears: Int
    let note: String

    let brackets: [TaxBracket]
    let medicareLevyRate: Double
    let medicareLevyThreshold: Double
    let concessionalCap: Double
    let contributionsTaxRate: Double

    /// Income-distribution anchors used to estimate a percentile.
    let distribution: [DistributionAnchor]
    /// Median personal income per state/territory.
    let regionMedians: [RegionMedian]
}

extension CountryConfig {
    static let australia = CountryConfig(
        name: "Australia",
        localeIdentifier: "en_AU",
        currencyCode: "AUD",
        revenueBody: "the ATO",
        maxSalary: 400_000,
        coffeePrice: 5.5,
        monthlyRent: 2_200,
        careerYears: 45,
        note: "AU resident rates 2025-26. Excludes offsets, HECS-HELP.",
        brackets: [
            .init(upTo: 18_200, rate: 0),
            .init(upTo: 45_000, rate: 0.16),
            .init(upTo: 135_000, rate: 0.30),
            .init(upTo: 190_000, rate: 0.37),
            .init(upTo: .infinity, rate: 0.45),
        ],
        medicareLevyRate: 0.02,
        medicareLevyThreshold: 27_222,
        concessionalCap: 30_000,
        contributionsTaxRate: 0.15,
        distribution: [
            .init(percentile: 0, income: 0),
            .init(percentile: 10, income: 30_000),
            .init(percentile: 25, income: 48_000),
            .init(percentile: 50, income: 72_000),
            .init(percentile: 75, income: 104_000),
            .init(percentile: 90, income: 140_000),
            .init(percentile: 95, income: 175_000),
            .init(percentile: 99, income: 290_000),
        ],
        regionMedians: [
            .init(code: "ACT", median: 90_000),
            .init(code: "WA", median: 84_000),
            .init(code: "NT", median: 78_000),
            .init(code: "NSW", median: 73_000),
            .init(code: "VIC", median: 69_000),
            .init(code: "QLD", median: 68_000),
            .init(code: "SA", median: 64_000),
            .init(code: "TAS", median: 61_000),
        ]
    )
}
