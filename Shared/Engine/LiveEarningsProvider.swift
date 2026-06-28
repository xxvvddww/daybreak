import Foundation

/// Convenience that combines the calculator and the day clock into a single
/// call. Used by the Today/Damage screens and the widget so they all derive
/// live figures identically.
struct LiveEarningsProvider: Sendable {
    let calculator: EarningsCalculator
    let clock = DayClock()

    init(config: CountryConfig = .australia) {
        calculator = EarningsCalculator(config: config)
    }

    func snapshot(
        inputs: ProfileInputs,
        at date: Date,
        calendar: Calendar = .current
    ) -> (breakdown: EarningsBreakdown, live: LiveEarnings) {
        let breakdown = calculator.breakdown(for: inputs)
        let (fraction, isRestDay) = clock.fraction(
            inputs: inputs, breakdown: breakdown, at: date, calendar: calendar
        )
        let live = calculator.live(breakdown: breakdown, fraction: fraction, isRestDay: isRestDay)
        return (breakdown, live)
    }
}
