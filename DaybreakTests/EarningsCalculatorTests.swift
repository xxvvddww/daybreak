import XCTest
@testable import Daybreak

/// Verifies the headline breakdown and live earnings for the default profile.
final class EarningsCalculatorTests: XCTestCase {
    let calc = EarningsCalculator(config: .australia)

    func testDefaultBreakdown() {
        let b = calc.breakdown(for: ProfileInputs())
        XCTAssertEqual(b.base, 95_000, accuracy: 0.001)
        XCTAssertEqual(b.superAmount, 11_400, accuracy: 0.001)            // 95,000 * 0.12
        XCTAssertEqual(b.paidHours, 7.5, accuracy: 0.001)                 // 8h − 30m break
        XCTAssertEqual(b.weeklyHours, 37.5, accuracy: 0.001)             // 7.5 * 5
        XCTAssertEqual(b.daysPerYear, 260)                               // 5 * 52
        XCTAssertEqual(b.levy, 1_900, accuracy: 0.001)
        XCTAssertEqual(b.tax, 21_188, accuracy: 0.001)                   // 19,288 + 1,900
        XCTAssertEqual(b.net, 73_812, accuracy: 0.001)
        XCTAssertEqual(b.effectiveRate, 21_188.0 / 95_000.0, accuracy: 0.00001)
        XCTAssertEqual(b.marginalRatePercent, 32)
        XCTAssertEqual(b.grossPerDay, 95_000.0 / 260.0, accuracy: 0.001)
        XCTAssertEqual(b.grossPerSecond, 95_000.0 / (260.0 * 27_000.0), accuracy: 1e-9)
    }

    func testSalaryIncludesSuper() {
        var input = ProfileInputs()
        input.salaryIncludesSuper = true
        let b = calc.breakdown(for: input)
        // base = 95,000 / 1.12 ; super = remainder
        XCTAssertEqual(b.base, 95_000.0 / 1.12, accuracy: 0.001)
        XCTAssertEqual(b.base + b.superAmount, 95_000, accuracy: 0.001)
    }

    func testOvernightShiftSpanWraps() {
        var input = ProfileInputs()
        input.startHour = 22
        input.endHour = 6
        input.hasBreak = false
        let b = calc.breakdown(for: input)
        XCTAssertEqual(b.spanHours, 8, accuracy: 0.001)   // 6 − 22 = −16, +24 = 8
        XCTAssertEqual(b.paidHours, 8, accuracy: 0.001)
    }

    func testLiveEarningsScaleWithFraction() {
        let b = calc.breakdown(for: ProfileInputs())
        let half = calc.live(breakdown: b, fraction: 0.5, isRestDay: false)
        XCTAssertEqual(half.earnedGross, b.grossPerDay * 0.5, accuracy: 0.001)
        XCTAssertEqual(half.earnedKeep + half.earnedTax, half.earnedGross, accuracy: 0.001)

        let rest = calc.live(breakdown: b, fraction: 0.5, isRestDay: true)
        XCTAssertEqual(rest.earnedGross, 0, accuracy: 0.001)
        XCTAssertTrue(rest.isRestDay)
    }

    func testFreedomSecondsWithinShift() {
        let b = calc.breakdown(for: ProfileInputs())
        XCTAssertGreaterThan(b.freedomSeconds, b.startSeconds)
        XCTAssertLessThan(b.freedomSeconds, b.startSeconds + b.spanSeconds)
    }
}
