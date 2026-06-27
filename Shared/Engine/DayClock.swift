import Foundation

/// Whether the app is showing the real time of day, or a sped-up demo loop.
enum EarningMode: String, CaseIterable, Codable, Sendable, Identifiable {
    case live
    case demo

    var id: String { rawValue }

    var label: String {
        switch self {
        case .live: "Live"
        case .demo: "Demo"
        }
    }
}

/// Computes how far through the working day we are.
///
/// - In `.live` mode the fraction comes from the real wall-clock time relative
///   to the user's start time and shift span, and rest days read as zero.
/// - In `.demo` mode the day loops every `demoCycleSeconds`, derived from
///   absolute time so the app and the widget stay in lock-step.
struct DayClock: Sendable {
    static let demoCycleSeconds: Double = 80

    func fraction(
        mode: EarningMode,
        inputs: ProfileInputs,
        breakdown: EarningsBreakdown,
        at date: Date,
        calendar: Calendar = .current
    ) -> (fraction: Double, isRestDay: Bool) {
        switch mode {
        case .demo:
            let t = date.timeIntervalSinceReferenceDate
            var f = t.truncatingRemainder(dividingBy: Self.demoCycleSeconds) / Self.demoCycleSeconds
            if f < 0 { f += 1 }
            return (f, false)

        case .live:
            if isRestDay(inputs: inputs, date: date, calendar: calendar) {
                return (0, true)
            }
            let comps = calendar.dateComponents([.hour, .minute, .second], from: date)
            let s = Double((comps.hour ?? 0) * 3600 + (comps.minute ?? 0) * 60 + (comps.second ?? 0))
            let start = breakdown.startSeconds
            let end = start + breakdown.spanSeconds
            let f: Double
            if s <= start { f = 0 }
            else if s >= end { f = 1 }
            else { f = (s - start) / breakdown.spanSeconds }
            return (f, false)
        }
    }

    /// True when `date` falls on a day the user does not work.
    /// Calendar weekday is 1 = Sunday … 7 = Saturday; the app indexes
    /// Monday = 0 … Sunday = 6.
    func isRestDay(inputs: ProfileInputs, date: Date, calendar: Calendar = .current) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        let todayIndex = (weekday + 5) % 7
        return !inputs.workDays.contains(todayIndex)
    }
}
