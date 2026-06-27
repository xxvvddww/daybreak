import WidgetKit
import SwiftUI

/// "Earned today" — the headline widget mirroring the home-screen card in the
/// design. Supports home-screen (small/medium) and lock-screen accessory sizes.
struct EarnedTodayWidget: Widget {
    let kind = "EarnedTodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DaybreakProvider()) { entry in
            EarnedTodayEntryView(entry: entry)
        }
        .configurationDisplayName("Earned today")
        .description("What you've earned so far today, and how it splits.")
        .supportedFamilies([
            .systemSmall, .systemMedium,
            .accessoryRectangular, .accessoryInline, .accessoryCircular,
        ])
    }
}

private struct EarnedTodayEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DaybreakEntry

    var body: some View {
        let figures = WidgetEngine.figures(for: entry)
        switch family {
        case .accessoryInline:
            inline(figures)
        case .accessoryCircular:
            circular(figures)
        case .accessoryRectangular:
            rectangular(figures)
        case .systemMedium:
            medium(figures)
        default:
            small(figures)
        }
    }

    // MARK: - Home screen

    private func small(_ f: (breakdown: EarningsBreakdown, live: LiveEarnings)) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer(minLength: 4)
            Text(DaybreakFormat.money(f.live.earnedGross))
                .font(.system(size: 30, weight: .medium, design: .monospaced))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            WidgetDayBar(fraction: f.live.fraction, effectiveRate: f.breakdown.effectiveRate)
                .padding(.top, 10)
        }
        .foregroundStyle(Brand.paper)
        .widgetContainerBackground { Brand.wallpaper(dark: false) }
    }

    private func medium(_ f: (breakdown: EarningsBreakdown, live: LiveEarnings)) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer(minLength: 4)
            Text(DaybreakFormat.money(f.live.earnedGross))
                .font(.system(size: 34, weight: .medium, design: .monospaced))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            WidgetDayBar(fraction: f.live.fraction, effectiveRate: f.breakdown.effectiveRate)
                .padding(.top, 10)
            HStack(spacing: 0) {
                split("You keep", DaybreakFormat.money(f.live.earnedKeep, fractionDigits: 0), Color(hex: "A6E8C6"), first: true)
                split("To ATO", DaybreakFormat.money(f.live.earnedTax, fractionDigits: 0), Color(hex: "F0B089"))
                split("Super", DaybreakFormat.money(f.live.earnedSuper, fractionDigits: 0), Color(hex: "F3D69A"))
            }
            .padding(.top, 12)
        }
        .foregroundStyle(Brand.paper)
        .widgetContainerBackground { Brand.wallpaper(dark: false) }
    }

    private var header: some View {
        HStack {
            Text("EARNED TODAY")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Brand.paper.opacity(0.82))
            Spacer()
            Image(systemName: "sun.max.fill")
                .font(.system(size: 13))
                .foregroundStyle(Brand.paper.opacity(0.9))
        }
    }

    private func split(_ label: String, _ value: String, _ dot: Color, first: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 5) {
                Circle().fill(dot).frame(width: 5, height: 5)
                Text(label)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Brand.paper.opacity(0.72))
                    .lineLimit(1)
            }
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Brand.paper)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, first ? 0 : 10)
    }

    // MARK: - Lock screen

    private func inline(_ f: (breakdown: EarningsBreakdown, live: LiveEarnings)) -> some View {
        Label("\(DaybreakFormat.money(f.live.earnedGross, fractionDigits: 0)) earned today",
              systemImage: "sun.max.fill")
    }

    private func circular(_ f: (breakdown: EarningsBreakdown, live: LiveEarnings)) -> some View {
        Gauge(value: min(max(f.live.fraction, 0), 1)) {
            Image(systemName: "sun.max.fill")
        } currentValueLabel: {
            Text(DaybreakFormat.big(f.live.earnedGross))
                .minimumScaleFactor(0.5)
        }
        .gaugeStyle(.accessoryCircular)
        .widgetContainerBackground { Color.clear }
    }

    private func rectangular(_ f: (breakdown: EarningsBreakdown, live: LiveEarnings)) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Earned today").font(.system(size: 12, weight: .semibold))
            Text(DaybreakFormat.money(f.live.earnedGross, fractionDigits: 0))
                .font(.system(size: 18, weight: .medium, design: .monospaced))
            ProgressView(value: min(max(f.live.fraction, 0), 1))
                .tint(.primary)
        }
        .widgetContainerBackground { Color.clear }
    }
}
