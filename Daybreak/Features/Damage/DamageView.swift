import SwiftUI

/// The Damage screen: the emotional gut-punch of what tax costs, framed in
/// cents, days, time and things you could otherwise buy.
struct DamageView: View {
    @Environment(ProfileStore.self) private var store
    private let provider = LiveEarningsProvider()
    private let tickInterval: Double = 0.5

    var body: some View {
        FeatureScreen {
            TimelineView(.periodic(from: .now, by: tickInterval)) { context in
                let snapshot = provider.snapshot(inputs: store.inputs, at: context.date)
                DamageContent(breakdown: snapshot.breakdown, live: snapshot.live, now: context.date)
            }
        }
    }
}

private struct DamageContent: View {
    @Environment(\.theme) private var theme
    let breakdown: EarningsBreakdown
    let live: LiveEarnings
    let now: Date

    private let damageCalculator = DamageCalculator()
    private let config = CountryConfig.australia

    var body: some View {
        let report = damageCalculator.report(breakdown: breakdown, now: now)

        VStack(alignment: .leading, spacing: 0) {
            header(report: report)
            paidTodayCard
            StatCard(
                bigText: "\(report.daysForGovernment) days",
                label: "You work this many days a year before you earn a cent for yourself.",
                subMarkdown: "Your personal tax freedom day is **\(DaybreakFormat.monthDay(report.taxFreedomDay))**. Everything you earn before then goes straight to the ATO.",
                color: theme.tax,
                info: "Effective tax rate (\(String(format: "%.1f", breakdown.effectiveRate * 100))%) × your working days per year (\(breakdown.daysPerYear))."
            )
            StatCard(
                bigText: DaybreakFormat.hourMinute(report.dailyTaxSeconds),
                label: "Of every working day handed to the ATO before you keep a dollar.",
                subMarkdown: "You clock in at **\(DaybreakFormat.clock(breakdown.startSeconds))**, but you don't start earning for yourself until **\(DaybreakFormat.clock(breakdown.freedomSeconds))**.",
                info: "Effective tax rate × your daily paid hours (\(String(format: "%.1f", breakdown.paidHours))h)."
            )
            StatCard(
                bigText: DaybreakFormat.money(report.lifetimeTax, fractionDigits: 0),
                label: "Gone to the ATO over a \(config.careerYears)-year career.",
                subMarkdown: "On today's salary with no pay rises. With raises, it's far more.",
                color: theme.tax,
                info: "This year's tax (\(DaybreakFormat.money(breakdown.tax, fractionDigits: 0))) × \(config.careerYears) years. Ignores pay rises and rate changes."
            )
            couldBuy(report: report)
            quote
        }
    }

    private func header(report: DamageReport) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                Text("The damage")
                    .sans(11, weight: .bold, relativeTo: .caption).tracking(1.6)
                    .textCase(.uppercase).foregroundStyle(theme.ink3)
                InfoButton(text: "Effective tax rate = total tax ÷ taxable income, shown as cents per dollar. Currently \(String(format: "%.1f", breakdown.effectiveRate * 100))%.")
            }
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("\(report.cents)")
                    .serif(80, weight: .medium, relativeTo: .largeTitle)
                Text("¢")
                    .serif(42, weight: .medium, relativeTo: .largeTitle)
            }
            .foregroundStyle(theme.tax)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(.vertical, 4)
            Text("of every dollar you earn never reaches your pocket")
                .serif(18.5, weight: .regular, relativeTo: .title3)
                .foregroundStyle(theme.ink)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 262)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .accessibilityElement(children: .combine)
    }

    private var paidTodayCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Paid to ATO today")
                    .sans(11, weight: .bold, relativeTo: .caption).tracking(1.2)
                    .textCase(.uppercase).foregroundStyle(theme.summaryMuted)
                Spacer()
                InfoButton(text: "Today's gross × your effective tax rate, accruing live.", dark: true)
            }
            Text(DaybreakFormat.money(live.earnedTax))
                .mono(36, weight: .medium, relativeTo: .largeTitle)
                .foregroundStyle(theme.tax)
                .minimumScaleFactor(0.5).lineLimit(1)
                .contentTransition(.numericText(value: live.earnedTax))
                .animation(.snappy(duration: 0.4), value: live.earnedTax)
                .padding(.top, 8)
            Text("Climbing every second you're on the clock.")
                .sans(12.5).foregroundStyle(theme.summaryMuted)
                .padding(.top, 7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 18).padding(.horizontal, 20)
        .background(theme.summary, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.top, 24).padding(.bottom, 8)
        .accessibilityElement(children: .combine)
    }

    private func couldBuy(report: DamageReport) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text("What the ATO takes each year could buy")
                    .sans(14.5, weight: .semibold).foregroundStyle(theme.ink)
                    .frame(maxWidth: 230, alignment: .leading)
                Spacer(minLength: 8)
                InfoButton(text: "This year's tax ÷ an indicative local price for each item.")
            }
            FlowLayout(spacing: 8, rowSpacing: 8) {
                Chip("\(report.coffees.formatted()) coffees")
                Chip("\(String(format: "%.1f", report.rentMonths)) months' rent")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 18)
        .padding(.bottom, 16)
        .overlay(alignment: .top) { Rectangle().fill(theme.hairline).frame(height: 1) }
        .padding(.top, 4)
    }

    private var quote: some View {
        Text("You never agreed to this split. They decided it for you.")
            .serif(15.5, weight: .regular, relativeTo: .body)
            .italic()
            .foregroundStyle(theme.ink2)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}
