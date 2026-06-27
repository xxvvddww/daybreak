import Foundation

/// Estimates where an income sits in the national distribution, and against
/// regional medians. Mirrors `pctile()` and the Stats tab logic.
struct IncomeDistribution: Sendable {
    let config: CountryConfig

    init(config: CountryConfig = .australia) {
        self.config = config
    }

    /// The percentile (0–99.5) an income falls at, linearly interpolated
    /// between the configured distribution anchors.
    func percentile(income: Double) -> Double {
        let anchors = config.distribution
        guard let first = anchors.first else { return 0 }
        if income <= first.income { return first.percentile }
        for i in 1..<anchors.count {
            if income <= anchors[i].income {
                let lower = anchors[i - 1]
                let upper = anchors[i]
                let span = upper.income - lower.income
                guard span != 0 else { return upper.percentile }
                return lower.percentile
                    + ((income - lower.income) / span) * (upper.percentile - lower.percentile)
            }
        }
        return 99.5
    }

    /// How far above (+) or below (−) a region's median an income sits, in percent.
    func differenceFromRegionMedian(income: Double, regionCode: String) -> Double {
        guard let region = config.regionMedians.first(where: { $0.code == regionCode }),
              region.median != 0 else { return 0 }
        return (income / region.median - 1) * 100
    }

    /// Region medians sorted high to low (for the comparison table).
    var regionsByMedianDescending: [CountryConfig.RegionMedian] {
        config.regionMedians.sorted { $0.median > $1.median }
    }
}
