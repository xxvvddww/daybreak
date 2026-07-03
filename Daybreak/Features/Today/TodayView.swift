import SwiftUI

/// The Today screen: a live, per-second view of what you've earned, how it's
/// split, and when each day you stop working for the ATO.
struct TodayView: View {
    @Environment(ProfileStore.self) private var store
    private let provider = LiveEarningsProvider()
    private let tickInterval: Double = 0.5

    var body: some View {
        FeatureScreen {
            TimelineView(.periodic(from: .now, by: tickInterval)) { context in
                let snapshot = provider.snapshot(inputs: store.inputs, at: context.date)
                TodayContent(breakdown: snapshot.breakdown, live: snapshot.live)
            }
        }
    }
}

private struct TodayContent: View {
    @Environment(\.theme) private var theme
    let breakdown: EarningsBreakdown
    let live: LiveEarnings

    private var superTax: Double { live.earnedSuper * CountryConfig.australia.contributionsTaxRate }
    private var superNet: Double { live.earnedSuper - superTax }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if live.isRestDay {
                restDayBlock
            } else {
                SunArcView(fraction: live.fraction, effectiveRate: breakdown.effectiveRate)
                    .padding(.top, 18)
                freedomLine
                    .padding(.top, 4)
                    .padding(.bottom, 24)
            }
            statGrid
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(headerCaption)
                .sans(11, weight: .semibold, relativeTo: .caption)
                .tracking(1.5)
                .foregroundStyle(theme.ink3)
                .textCase(.uppercase)
            Text(DaybreakFormat.money(live.earnedGross))
                .mono(54, weight: .medium, relativeTo: .largeTitle)
                .foregroundStyle(theme.ink)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .contentTransition(.numericText(value: live.earnedGross))
                .animation(.snappy(duration: 0.4), value: live.earnedGross)
            if live.isRestDay {
                Text("You're off the clock today")
                    .sans(13, weight: .medium)
                    .foregroundStyle(theme.ink3)
            } else {
                styledText([
                    TextRun(string: "+\(DaybreakFormat.money(breakdown.grossPerSecond))", color: theme.keep),
                    TextRun(string: " / second on the clock", color: theme.ink3),
                ])
                .sans(13, weight: .medium)
            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.top, 12)
        .accessibilityElement(children: .combine)
    }

    private var headerCaption: String {
        live.isRestDay ? "Today · Day off" : "Earned today · \(DaybreakFormat.clock(live.nowSeconds))"
    }

    private var freedomLine: some View {
        HStack(alignment: .top, spacing: 13) {
            SunIcon(size: 26, color: live.beforeFreedom ? theme.ink3 : theme.gold)
                .padding(.top, 2)
            freedomText
                .serif(17.5, weight: .regular, relativeTo: .body)
                .foregroundStyle(theme.ink)
                .lineSpacing(3)
        }
        .padding(.horizontal, 2)
    }

    private var freedomText: Text {
        let clockStr = DaybreakFormat.clock(breakdown.freedomSeconds)
        if live.beforeFreedom {
            return styledText([
                TextRun(string: "Until "),
                TextRun(string: clockStr, color: theme.tax, bold: true),
                TextRun(string: " you're working for the ATO. After that, every cent is yours."),
            ])
        } else {
            return styledText([
                TextRun(string: "Since "),
                TextRun(string: clockStr, color: theme.keep, bold: true),
                TextRun(string: " you've been earning for yourself. The taxman's already paid."),
            ])
        }
    }

    private var restDayBlock: some View {
        VStack(spacing: 0) {
            Image(systemName: "moon.fill")
                .font(.system(size: 30))
                .foregroundStyle(theme.gold)
                .frame(width: 66, height: 66)
                .background(theme.surface2, in: Circle())
                .padding(.bottom, 16)
            Text("Not a working day")
                .serif(24, weight: .semibold, relativeTo: .title)
                .foregroundStyle(theme.ink)
            Text("You're not scheduled to work today, so nothing's being earned or taxed. Enjoy it.")
                .serif(16.5, weight: .regular, relativeTo: .body)
                .foregroundStyle(theme.ink2)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.top, 8)
                .frame(maxWidth: 266)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 28)
        .padding(.bottom, 24)
    }

    private var statGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            StatBox(label: "You keep", value: DaybreakFormat.money(live.earnedKeep), dot: theme.keep)
            StatBox(label: "ATO takes", value: DaybreakFormat.money(live.earnedTax), dot: theme.tax)
            StatBox(label: "Into super", value: DaybreakFormat.money(superNet), dot: theme.gold)
            StatBox(label: "Super tax", value: DaybreakFormat.money(superTax), dot: theme.tax)
        }
    }
}
