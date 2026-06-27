import XCTest
@testable import Daybreak

final class PayRatesTests: XCTestCase {
    let calc = EarningsCalculator(config: .australia)
    let rates = PayRates()

    func testOnTheClockRates() {
        let b = calc.breakdown(for: ProfileInputs())
        let rows = rates.rates(amount: b.base, breakdown: b, inputs: ProfileInputs(), aroundTheClock: false)
        let byLabel = Dictionary(uniqueKeysWithValues: rows.map { ($0.label, $0.value) })

        XCTAssertEqual(byLabel["Per year"]!, 95_000, accuracy: 0.001)
        XCTAssertEqual(byLabel["Per month"]!, 95_000.0 / 12.0, accuracy: 0.001)
        XCTAssertEqual(byLabel["Per day"]!, 95_000.0 / 260.0, accuracy: 0.001)
        XCTAssertEqual(byLabel["Per week"]!, (95_000.0 / 260.0) * 5, accuracy: 0.001)
        XCTAssertEqual(byLabel["Per second"]!, 95_000.0 / (260.0 * 27_000.0), accuracy: 1e-9)
    }

    func testAroundTheClockRates() {
        let b = calc.breakdown(for: ProfileInputs())
        let rows = rates.rates(amount: b.base, breakdown: b, inputs: ProfileInputs(), aroundTheClock: true)
        let byLabel = Dictionary(uniqueKeysWithValues: rows.map { ($0.label, $0.value) })

        XCTAssertEqual(byLabel["Per second"]!, 95_000.0 / (365.0 * 24.0 * 3600.0), accuracy: 1e-9)
        XCTAssertEqual(byLabel["Per week"]!, 95_000.0 / 52.0, accuracy: 0.001)
    }
}

final class FormattingTests: XCTestCase {
    func testBig() {
        XCTAssertEqual(DaybreakFormat.big(540), "$540")
        XCTAssertEqual(DaybreakFormat.big(48_000), "$48k")
        XCTAssertEqual(DaybreakFormat.big(1_250_000), "$1.3m")
        XCTAssertEqual(DaybreakFormat.big(12_000_000), "$12m")
    }

    func testClock() {
        XCTAssertEqual(DaybreakFormat.clock(9 * 3600), "9:00am")
        XCTAssertEqual(DaybreakFormat.clock(17 * 3600), "5:00pm")
        XCTAssertEqual(DaybreakFormat.clock(0), "12:00am")
        XCTAssertEqual(DaybreakFormat.clock(12 * 3600), "12:00pm")
        XCTAssertEqual(DaybreakFormat.clock(38_823), "10:47am")
    }

    func testHourMinute() {
        XCTAssertEqual(DaybreakFormat.hourMinute(6_021), "1h 40m")
        XCTAssertEqual(DaybreakFormat.hourMinute(2_400), "40m")
    }

    func testMoneyIsLocaleAware() {
        // en_AU uses a leading $ and grouping separators.
        let s = DaybreakFormat.money(73_812, fractionDigits: 0)
        XCTAssertTrue(s.contains("73,812"))
        XCTAssertTrue(s.hasPrefix("$"))
    }
}

final class DayClockTests: XCTestCase {
    let calc = EarningsCalculator(config: .australia)
    let clock = DayClock()

    private func calendar() -> Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Australia/Perth")!
        return c
    }

    func testLiveBeforeStartIsZero() {
        let b = calc.breakdown(for: ProfileInputs())
        let cal = calendar()
        // A Wednesday at 7am, before the 9am start.
        let date = cal.date(from: DateComponents(year: 2026, month: 6, day: 24, hour: 7))!
        let result = clock.fraction(mode: .live, inputs: ProfileInputs(), breakdown: b, at: date, calendar: cal)
        XCTAssertEqual(result.fraction, 0, accuracy: 0.0001)
        XCTAssertFalse(result.isRestDay)
    }

    func testLiveMiddayMidShift() {
        let b = calc.breakdown(for: ProfileInputs())
        let cal = calendar()
        // Wednesday 1pm: 4h into an 8h span → 0.5
        let date = cal.date(from: DateComponents(year: 2026, month: 6, day: 24, hour: 13))!
        let result = clock.fraction(mode: .live, inputs: ProfileInputs(), breakdown: b, at: date, calendar: cal)
        XCTAssertEqual(result.fraction, 0.5, accuracy: 0.0001)
    }

    func testRestDayDetected() {
        let b = calc.breakdown(for: ProfileInputs())   // works Mon–Fri
        let cal = calendar()
        // Sunday 28 June 2026.
        let date = cal.date(from: DateComponents(year: 2026, month: 6, day: 28, hour: 12))!
        let result = clock.fraction(mode: .live, inputs: ProfileInputs(), breakdown: b, at: date, calendar: cal)
        XCTAssertTrue(result.isRestDay)
        XCTAssertEqual(result.fraction, 0, accuracy: 0.0001)
    }

    func testDemoLoops() {
        let b = calc.breakdown(for: ProfileInputs())
        let cal = calendar()
        let result = clock.fraction(mode: .demo, inputs: ProfileInputs(), breakdown: b,
                                    at: Date(timeIntervalSinceReferenceDate: 40), calendar: cal)
        XCTAssertEqual(result.fraction, 0.5, accuracy: 0.0001)   // 40 / 80
        XCTAssertFalse(result.isRestDay)
    }
}
