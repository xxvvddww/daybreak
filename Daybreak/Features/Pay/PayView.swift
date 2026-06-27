import SwiftUI

/// The Pay screen: your salary expressed as a rate across every time unit, plus
/// an annual breakdown and a per-pay-period table.
struct PayView: View {
    @Environment(\.theme) private var theme
    @Environment(ProfileStore.self) private var store
    @State private var afterTax = false
    @State private var aroundTheClock = false

    private let calculator = EarningsCalculator()
    private let rateBuilder = PayRates()

    var body: some View {
        let inputs = store.inputs
        let breakdown = calculator.breakdown(for: inputs)
        let amount = afterTax ? breakdown.net : breakdown.base
        let rows = rateBuilder.rates(amount: amount, breakdown: breakdown, inputs: inputs, aroundTheClock: aroundTheClock)

        FeatureScreen {
            ScreenTitle("Pay calculator")
            guideBox
            SectionLabel("Your rate")
            SegmentedPicker(selection: $afterTax, options: [
                SegmentOption(value: false, label: "Before tax"),
                SegmentOption(value: true, label: "After tax"),
            ])
            .padding(.bottom, 10)
            SegmentedPicker(selection: $aroundTheClock, options: [
                SegmentOption(value: false, label: "On the clock"),
                SegmentOption(value: true, label: "Around the clock"),
            ])
            .padding(.bottom, 16)

            ratesCard(rows)
            Text(rateCaption(breakdown: breakdown, inputs: inputs))
                .sans(12)
                .foregroundStyle(theme.ink3)
                .lineSpacing(2)
                .padding(.top, 10)
                .padding(.bottom, 26)

            SectionLabel("Annual breakdown")
            breakdownCard(breakdown: breakdown, inputs: inputs)
                .padding(.bottom, 26)

            SectionLabel("Per pay period")
            perPeriodCard(breakdown: breakdown, payFrequency: inputs.payFrequency)
        }
    }

    // MARK: - Pieces

    private var guideBox: some View {
        mdText("A guide only. For anything you'll rely on, check [paycalculator.com.au](https://paycalculator.com.au/).")
            .sans(12.5)
            .foregroundStyle(theme.ink2)
            .lineSpacing(2)
            .tint(theme.keep)
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.keepSoft, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.bottom, 20)
    }

    private func fmt(_ value: Double) -> String {
        DaybreakFormat.money(value, fractionDigits: value < 1 ? 4 : value < 100 ? 2 : 0)
    }

    private func ratesCard(_ rows: [PayRate]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                HStack {
                    Text(row.label)
                        .sans(14, weight: row.emphasized ? .bold : .medium)
                        .foregroundStyle(row.emphasized ? theme.ink : theme.ink2)
                    Spacer(minLength: 8)
                    Text(fmt(row.value))
                        .mono(row.emphasized ? 19 : 15, weight: .medium)
                        .foregroundStyle(row.emphasized ? theme.keep : theme.ink)
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 18)
                .background(row.emphasized ? theme.surface2 : Color.clear)
                .overlay(alignment: .top) {
                    if index > 0 { Rectangle().fill(theme.hairline).frame(height: 1) }
                }
            }
        }
        .glassCard()
    }

    private func rateCaption(breakdown: EarningsBreakdown, inputs: ProfileInputs) -> String {
        if aroundTheClock {
            return "Salary spread across every hour of the year — awake, asleep, on holiday."
        }
        let days = inputs.workDays.count
        return "Based on \(String(format: "%.1f", breakdown.paidHours))h paid per day, \(days) \(days == 1 ? "day" : "days") a week."
    }

    private func breakdownCard(breakdown b: EarningsBreakdown, inputs: ProfileInputs) -> some View {
        VStack(spacing: 0) {
            KeyValueLine(
                label: inputs.salaryIncludesSuper ? "Package (incl. super)" : "Base salary",
                value: DaybreakFormat.money(inputs.salaryIncludesSuper ? inputs.salary : b.base, fractionDigits: 0)
            )
            if b.superAmount > 0 {
                KeyValueLine(label: "Superannuation",
                             value: DaybreakFormat.money(b.superAmount, fractionDigits: 0),
                             valueColor: theme.keep)
            }
            KeyValueLine(label: "Taxable income", value: DaybreakFormat.money(b.base, fractionDigits: 0))
            KeyValueLine(label: "Income tax",
                         value: "− " + DaybreakFormat.money(b.incomeTaxOnly, fractionDigits: 0),
                         valueColor: theme.tax)
            if b.levy > 0 {
                KeyValueLine(label: "Medicare levy",
                             value: "− " + DaybreakFormat.money(b.levy, fractionDigits: 0),
                             valueColor: theme.tax)
            }
            Rectangle().fill(theme.hairline).frame(height: 1).padding(.vertical, 6)
            KeyValueLine(label: "Take-home pay", value: DaybreakFormat.money(b.net, fractionDigits: 0), bold: true)
            KeyValueLine(label: "Effective tax rate", value: String(format: "%.1f%%", b.effectiveRate * 100))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 18)
        .glassCard()
    }

    private func perPeriodCard(breakdown b: EarningsBreakdown, payFrequency: PayFrequency) -> some View {
        let showSuper = b.superAmount > 0
        let periods: [(label: String, divisor: Double, freq: PayFrequency?)] = [
            ("Weekly", 52, .weekly),
            ("Fortnightly", 26, .fortnightly),
            ("Monthly", 12, .monthly),
            ("Annual", 1, nil),
        ]
        return VStack(spacing: 0) {
            HStack {
                Text("Period").frame(maxWidth: .infinity, alignment: .leading)
                Text("Net").frame(width: 70, alignment: .trailing)
                Text("Tax").frame(width: 70, alignment: .trailing)
                if showSuper { Text("Super").frame(width: 70, alignment: .trailing) }
            }
            .sans(10.5, weight: .bold)
            .tracking(0.5)
            .textCase(.uppercase)
            .foregroundStyle(theme.ink3)
            .padding(.vertical, 11)
            .padding(.horizontal, 16)
            .background(theme.surface2)

            ForEach(periods, id: \.label) { period in
                let isMine = period.freq == payFrequency
                HStack {
                    Text(period.label)
                        .sans(13.5, weight: isMine ? .bold : .semibold)
                        .foregroundStyle(isMine ? theme.keep : theme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(DaybreakFormat.money(b.net / period.divisor, fractionDigits: 0))
                        .mono(12.5).foregroundStyle(theme.ink).frame(width: 70, alignment: .trailing)
                    Text(DaybreakFormat.money(b.tax / period.divisor, fractionDigits: 0))
                        .mono(12.5).foregroundStyle(theme.tax).frame(width: 70, alignment: .trailing)
                    if showSuper {
                        Text(DaybreakFormat.money(b.superAmount / period.divisor, fractionDigits: 0))
                            .mono(12.5).foregroundStyle(theme.keep).frame(width: 70, alignment: .trailing)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(isMine ? theme.surface2 : Color.clear)
                .overlay(alignment: .top) { Rectangle().fill(theme.hairline).frame(height: 1) }
            }
        }
        .glassCard()
    }
}
