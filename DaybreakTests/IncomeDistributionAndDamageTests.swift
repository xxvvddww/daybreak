import XCTest
@testable import Daybreak

final class IncomeDistributionTests: XCTestCase {
    let dist = IncomeDistribution(config: .australia)

    func testPercentileInterpolation() {
        // 95,000 sits between p50 ($72k) and p75 ($104k):
        // 50 + (23000/32000) * 25 ≈ 67.97
        XCTAssertEqual(dist.percentile(income: 95_000), 67.969, accuracy: 0.01)
        XCTAssertEqual(dist.percentile(income: 72_000), 50, accuracy: 0.01)
        XCTAssertEqual(dist.percentile(income: 0), 0, accuracy: 0.01)
    }

    func testTopOfDistributionSaturates() {
        XCTAssertEqual(dist.percentile(income: 1_000_000), 99.5, accuracy: 0.01)
    }

    func testRegionComparison() {
        // 95,000 vs WA median 84,000 → +13.09%
        XCTAssertEqual(dist.differenceFromRegionMedian(income: 95_000, regionCode: "WA"),
                       13.095, accuracy: 0.01)
        XCTAssertEqual(dist.regionsByMedianDescending.first?.code, "ACT")
    }
}

final class DamageReportTests: XCTestCase {
    let calc = EarningsCalculator(config: .australia)
    let damage = DamageCalculator(config: .australia)

    private func fixedCalendar() -> Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Australia/Perth")!
        return c
    }

    func testDamageFiguresForDefaultProfile() {
        let b = calc.breakdown(for: ProfileInputs())
        let cal = fixedCalendar()
        let now = cal.date(from: DateComponents(year: 2026, month: 6, day: 27, hour: 12))!
        let report = damage.report(breakdown: b, now: now, calendar: cal)

        XCTAssertEqual(report.cents, 22)                      // round(0.2230 * 100)
        XCTAssertEqual(report.daysForGovernment, 58)          // round(0.2230 * 260)
        XCTAssertEqual(report.lifetimeTax, 21_188 * 45, accuracy: 0.001)
        XCTAssertEqual(report.coffees, 3_852)                 // round(21,188 / 5.5)
        XCTAssertEqual(report.rentMonths, 21_188.0 / 2_200.0, accuracy: 0.001)

        let freedomYear = cal.component(.year, from: report.taxFreedomDay)
        XCTAssertEqual(freedomYear, 2026)
    }
}
