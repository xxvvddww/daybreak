import XCTest
@testable import Daybreak

final class SuperProjectionTests: XCTestCase {
    let proj = SuperProjection(config: .australia)

    func testFutureValueFactor() {
        XCTAssertEqual(proj.fvFactor(rate: 0, years: 45), 45, accuracy: 0.001)
        // (1.07^45 − 1) / 0.07 ≈ 285.749
        XCTAssertEqual(proj.fvFactor(rate: 0.07, years: 45), 285.7493, accuracy: 0.05)
    }

    func testBaseModelNoExtra() {
        let m = proj.model(perPay: 0, employerGross: 11_400, growthRate: 0.07,
                           payFrequency: .fortnightly, years: 45)
        XCTAssertEqual(m.grossExtra, 0, accuracy: 0.001)
        XCTAssertFalse(m.over)
        XCTAssertEqual(m.annualNet, 11_400 * 0.85, accuracy: 0.001)        // 15% contributions tax
        XCTAssertEqual(m.balance, 11_400 * 0.85 * proj.fvFactor(rate: 0.07, years: 45), accuracy: 1.0)
    }

    func testExtraContributionWithinCap() {
        let m = proj.model(perPay: 200, employerGross: 11_400, growthRate: 0.07,
                           payFrequency: .fortnightly, years: 45)
        XCTAssertEqual(m.grossExtra, 5_200, accuracy: 0.001)               // 200 * 26
        XCTAssertEqual(m.cappedExtra, 5_200, accuracy: 0.001)             // under cap room (18,600)
        XCTAssertFalse(m.over)
        XCTAssertEqual(m.annualNet, (11_400 + 5_200) * 0.85, accuracy: 0.001)
    }

    func testExceedingConcessionalCapIsClamped() {
        // Cap room = 30,000 − 11,400 = 18,600. 1,000/pay * 26 = 26,000 > cap room.
        let m = proj.model(perPay: 1_000, employerGross: 11_400, growthRate: 0.07,
                           payFrequency: .fortnightly, years: 45)
        XCTAssertTrue(m.over)
        XCTAssertEqual(m.cappedExtra, 18_600, accuracy: 0.001)
    }

    func testSeriesGrowsMonotonically() {
        let series = proj.series(annualNet: 9_690, growthRate: 0.07, years: 45)
        XCTAssertEqual(series.count, 46)              // 0...45
        XCTAssertEqual(series[0], 0, accuracy: 0.001) // fvFactor(r, 0) = 0
        for i in 1..<series.count {
            XCTAssertGreaterThan(series[i], series[i - 1])
        }
    }
}
