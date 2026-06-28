import Foundation

/// Computes how far through the working day we are, from the real wall-clock
/// time relative to the user's start time and shift span. Days the user does
/// not work read as zero.
struct DayClock: Sendable {
    func fraction(
        inputs: ProfileInputs,
        breakdown: EarningsBreakdown,
        at date: Date,
        calendar: Calendar = .current
    ) -> (fraction: Double, isRestDay: Bool) {
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

    /// True when `date` falls on a day the user does not work.
    /// Calendar weekday is 1 = Sunday … 7 = Saturday; the app indexes
    /// Monday = 0 … Sunday = 6.
    func isRestDay(inputs: ProfileInputs, date: Date, calendar: Calendar = .current) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        let todayIndex = (weekday + 5) % 7
        return !inputs.workDays.contains(todayIndex)
    }
}
