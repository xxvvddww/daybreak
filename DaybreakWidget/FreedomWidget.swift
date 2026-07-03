import WidgetKit
import SwiftUI

/// "Freedom" — when each day you stop working for the ATO and start earning for
/// yourself. Mirrors the design's freedom widget.
struct FreedomWidget: Widget {
    let kind = "FreedomWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DaybreakProvider()) { entry in
            FreedomEntryView(entry: entry)
        }
        .configurationDisplayName("Tax freedom")
        .description("The time each day you start earning for yourself.")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryCircular])
    }
}

private struct FreedomEntryView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var scheme
    let entry: DaybreakEntry

    var body: some View {
        let f = WidgetEngine.figures(for: entry)
        let isFree = f.live.fraction >= f.breakdown.effectiveRate
        let isRestDay = f.live.isRestDay
        let freedom = DaybreakFormat.clock(f.breakdown.freedomSeconds)

        switch family {
        case .accessoryCircular:
            Gauge(value: min(max(f.live.fraction, 0), 1)) {
                Image(systemName: isFree ? "sun.max.fill" : "sun.haze.fill")
            }
            .gaugeStyle(.accessoryCircular)
            .widgetContainerBackground { Color.clear }

        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(isRestDay ? "Today" : (isFree ? "Earning for" : "Working until"))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                Text(isRestDay ? "Day off" : (isFree ? "yourself" : freedom))
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .widgetContainerBackground { Color.clear }

        default:
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: isRestDay ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(isFree ? Color(hex: "FBE3B4") : Brand.paper.opacity(0.5))
                Spacer(minLength: 8)
                Text(isRestDay ? "TODAY" : (isFree ? "EARNING FOR" : "WORKING UNTIL"))
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1.0)
                    .foregroundStyle(Brand.paper.opacity(0.62))
                Text(isRestDay ? "Day off" : (isFree ? "yourself" : freedom))
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundStyle(Brand.paper)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Brand.paper)
            .widgetContainerBackground { Brand.wallpaper(dark: scheme == .dark) }
        }
    }
}
