import WidgetKit
import SwiftUI

/// One timeline entry: a point in time plus the shared profile snapshot. The
/// figures are derived from `entry.date` at render time so each entry shows the
/// correct accrued amount.
struct DaybreakEntry: TimelineEntry {
    let date: Date
    let snapshot: SharedSnapshot
}

/// Reads the App Group snapshot and produces a timeline that refreshes through
/// the next few hours. WidgetKit can't tick per-second, so we step the timeline
/// at coarse intervals and recompute the live figure for each entry's date.
struct DaybreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> DaybreakEntry {
        DaybreakEntry(date: Date(), snapshot: .placeholder(updatedAt: Date()))
    }

    func getSnapshot(in context: Context, completion: @escaping (DaybreakEntry) -> Void) {
        completion(DaybreakEntry(date: Date(), snapshot: SharedStore.load() ?? .placeholder(updatedAt: Date())))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DaybreakEntry>) -> Void) {
        let snapshot = SharedStore.load() ?? .placeholder(updatedAt: Date())
        let now = Date()

        // Timeline entries are cheap (only reloads count against the WidgetKit
        // budget), so tick every minute while the user is on the clock — the
        // earned figure visibly moves — and every 15 minutes otherwise.
        let breakdown = EarningsCalculator().breakdown(for: snapshot.inputs)
        let clock = DayClock()
        let calendar = Calendar.current

        var entries = [DaybreakEntry(date: now, snapshot: snapshot)]
        for minute in 1...360 {
            let date = now.addingTimeInterval(Double(minute) * 60)
            let comps = calendar.dateComponents([.hour, .minute], from: date)
            let secondsOfDay = Double((comps.hour ?? 0) * 3600 + (comps.minute ?? 0) * 60)
            let onTheClock = !clock.isRestDay(inputs: snapshot.inputs, date: date, calendar: calendar)
                && secondsOfDay >= breakdown.startSeconds
                && secondsOfDay <= breakdown.startSeconds + breakdown.spanSeconds
            let keep = onTheClock ? (minute <= 180 || minute % 5 == 0) : (minute % 15 == 0)
            if keep {
                entries.append(DaybreakEntry(date: date, snapshot: snapshot))
            }
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

/// Derives display figures for an entry, shared by all widget views.
enum WidgetEngine {
    private static let provider = LiveEarningsProvider()

    static func figures(for entry: DaybreakEntry) -> (breakdown: EarningsBreakdown, live: LiveEarnings) {
        provider.snapshot(inputs: entry.snapshot.inputs, at: entry.date)
    }
}

/// A compact day-progress bar used in the system widgets, matching the app's
/// glass day bar (tax portion + keep portion + marker).
struct WidgetDayBar: View {
    var fraction: Double
    var effectiveRate: Double

    var body: some View {
        let split = min(max(effectiveRate, 0), 1)
        let progress = min(max(fraction, 0), 1)
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.22)).frame(height: 4)
                HStack(spacing: 0) {
                    Rectangle().fill(Color(hex: "E89B72")).frame(width: w * split)
                    Rectangle().fill(Color.white.opacity(0.88))
                }
                .frame(height: 4)
                .clipShape(Capsule())
                Circle()
                    .fill(.white)
                    .frame(width: 9, height: 9)
                    .shadow(color: .black.opacity(0.35), radius: 1.5, y: 1)
                    .offset(x: max(0, w * progress - 4.5))
            }
            .frame(height: geo.size.height, alignment: .center)
        }
        .frame(height: 9)
    }
}

extension View {
    /// Wraps the required `containerBackground` so callers read cleanly.
    func widgetContainerBackground<Background: View>(@ViewBuilder _ background: () -> Background) -> some View {
        containerBackground(for: .widget, alignment: .center) { background() }
    }
}
