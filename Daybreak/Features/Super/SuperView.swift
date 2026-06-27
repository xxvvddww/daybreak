import SwiftUI

/// The Super screen: employer contributions, the 15% contributions-tax gap,
/// how compounding works, and an interactive salary-sacrifice model.
struct SuperView: View {
    @Environment(\.theme) private var theme
    @Environment(ProfileStore.self) private var store

    @State private var growthPercent = 7
    @State private var extraPerPay: Double = 0

    private let calculator = EarningsCalculator()
    private let projection = SuperProjection()
    private let config = CountryConfig.australia

    var body: some View {
        let inputs = store.inputs
        let breakdown = calculator.breakdown(for: inputs)
        let plan = buildPlan(breakdown: breakdown, payFrequency: inputs.payFrequency)

        FeatureScreen {
            ScreenTitle("Super")
            headline(breakdown: breakdown)

            SectionLabel("Tax on your super")
            taxCard(plan: plan)
            taxNote(marginalRate: breakdown.marginalRatePercent)

            SectionLabel("How compounding works")
            compoundingCard(plan: plan)

            SectionLabel("Model it")
            Text("Expected growth (net of fund tax; fees vary)")
                .sans(11).foregroundStyle(theme.ink3).padding(.bottom, 8)
            SegmentedPicker(selection: $growthPercent, options: [
                SegmentOption(value: 5, label: "5% cautious"),
                SegmentOption(value: 7, label: "7% balanced"),
                SegmentOption(value: 9, label: "9% growth"),
            ])
            .padding(.bottom, 14)

            extraPerPayRow(payFrequency: inputs.payFrequency)
                .padding(.bottom, 14)
            impactNote(plan: plan)

            SectionLabel("Balance over \(plan.years) years").padding(.top, 22)
            GrowthChartView(lines: plan.chartLines, years: plan.years)
            legend(plan.chartLines).padding(.top, 12)

            SectionLabel("If you added…").padding(.top, 22)
            modelTable(plan: plan)

            disclaimer.padding(.top, 16)
        }
    }

    // MARK: - Plan

    private struct Plan {
        let years: Int
        let employerGross: Double
        let models: [SuperModelResult]
        let base0: SuperModelResult
        let mine: SuperModelResult
        let delta: Double
        let growthPercentOfBalance: Int
        let concessionalGross: Double
        let concessionalTax: Double
        let dollarGrowsTo: Int
        let chartLines: [GrowthLine]
    }

    private func buildPlan(breakdown: EarningsBreakdown, payFrequency: PayFrequency) -> Plan {
        let years = config.careerYears
        let r = Double(growthPercent) / 100
        let employerGross = breakdown.superAmount

        var levels: [Double] = [0, 100, 200, 300]
        if extraPerPay > 0, !levels.contains(extraPerPay) { levels.append(extraPerPay) }
        levels.sort()

        let models = levels.map {
            projection.model(perPay: $0, employerGross: employerGross,
                             growthRate: r, payFrequency: payFrequency, years: years)
        }
        let base0 = projection.model(perPay: 0, employerGross: employerGross,
                                     growthRate: r, payFrequency: payFrequency, years: years)
        let mine = projection.model(perPay: extraPerPay, employerGross: employerGross,
                                    growthRate: r, payFrequency: payFrequency, years: years)
        let delta = mine.balance - base0.balance

        let contributedNet = mine.annualNet * Double(years)
        let growthPart = max(0, mine.balance - contributedNet)
        let growthPct = mine.balance > 0 ? Int((growthPart / mine.balance * 100).rounded()) : 0

        let concGross = employerGross + mine.cappedExtra
        let concTax = concGross * config.contributionsTaxRate

        let lineColors: [Color] = [theme.ink3, theme.keep, theme.gold, theme.tax, Color(hex: "6E86A8")]
        let chartLines: [GrowthLine] = models.enumerated().map { index, model in
            GrowthLine(
                label: model.perPay == 0 ? "$0" : "+$\(Int(model.perPay))",
                color: lineColors[min(index, lineColors.count - 1)],
                series: projection.series(annualNet: model.annualNet, growthRate: r, years: years),
                isYou: model.perPay == extraPerPay && extraPerPay > 0
            )
        }

        return Plan(
            years: years, employerGross: employerGross, models: models, base0: base0, mine: mine,
            delta: delta, growthPercentOfBalance: growthPct, concessionalGross: concGross,
            concessionalTax: concTax, dollarGrowsTo: Int(pow(1 + r, Double(years)).rounded()),
            chartLines: chartLines
        )
    }

    // MARK: - Pieces

    private func headline(breakdown: EarningsBreakdown) -> some View {
        VStack(spacing: 6) {
            Text("Employer super this year")
                .sans(11, weight: .bold, relativeTo: .caption).tracking(1.4)
                .textCase(.uppercase).foregroundStyle(theme.ink3)
            Text(DaybreakFormat.money(breakdown.superAmount, fractionDigits: 0))
                .mono(46, weight: .medium, relativeTo: .largeTitle)
                .foregroundStyle(theme.keep)
                .minimumScaleFactor(0.5).lineLimit(1)
            Text("At \(String(format: "%.1f", breakdown.superRate * 100))% contribution")
                .sans(13, weight: .medium).foregroundStyle(theme.ink2)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.top, 2)
        .padding(.bottom, 22)
        .accessibilityElement(children: .combine)
    }

    private func taxCard(plan: Plan) -> some View {
        VStack(spacing: 0) {
            KeyValueLine(label: "Going into super this year",
                         value: DaybreakFormat.money(plan.concessionalGross, fractionDigits: 0))
            KeyValueLine(label: "Contributions tax (15%)",
                         value: "− " + DaybreakFormat.money(plan.concessionalTax, fractionDigits: 0),
                         valueColor: theme.tax)
            Rectangle().fill(theme.hairline).frame(height: 1).padding(.vertical, 6)
            KeyValueLine(label: "Actually invested",
                         value: DaybreakFormat.money(plan.concessionalGross - plan.concessionalTax, fractionDigits: 0),
                         bold: true)
        }
        .padding(.vertical, 8).padding(.horizontal, 18)
        .glassCard()
        .padding(.bottom, 10)
    }

    private func taxNote(marginalRate: Int) -> some View {
        styledText([
            TextRun(string: "Super is taxed at "),
            TextRun(string: "15%", color: theme.ink, bold: true),
            TextRun(string: " going in — well under your "),
            TextRun(string: "\(marginalRate)%", color: theme.ink, bold: true),
            TextRun(string: " marginal rate. That gap is the whole point of salary sacrificing."),
        ])
        .sans(12.5).foregroundStyle(theme.ink2).lineSpacing(3)
        .padding(.bottom, 26)
    }

    private func compoundingCard(plan: Plan) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            styledText([
                TextRun(string: "Your super earns returns, then those returns earn returns too. The earlier a dollar goes in, the more times it grows. At \(growthPercent)%, a dollar left for \(plan.years) years becomes about "),
                TextRun(string: "$\(plan.dollarGrowsTo)", color: theme.ink, bold: true),
                TextRun(string: "."),
            ])
            .sans(13.5).foregroundStyle(theme.ink2).lineSpacing(3)
            .padding(.bottom, 16)

            compoundingBar(growthPct: plan.growthPercentOfBalance)

            styledText([
                TextRun(string: "Of your projected "),
                TextRun(string: DaybreakFormat.big(plan.mine.balance), color: theme.ink, bold: true),
                TextRun(string: ", about "),
                TextRun(string: "\(plan.growthPercentOfBalance)%", color: theme.keep, bold: true),
                TextRun(string: " is growth you never lifted a finger for."),
            ])
            .sans(12.5).foregroundStyle(theme.ink3).lineSpacing(2)
            .padding(.top, 12)
        }
        .padding(.vertical, 18).padding(.horizontal, 20)
        .glassCard()
        .padding(.bottom, 26)
    }

    private func compoundingBar(growthPct: Int) -> some View {
        let putIn = max(0, 100 - growthPct)
        return GeometryReader { geo in
            let width = geo.size.width
            HStack(spacing: 0) {
                ZStack {
                    theme.keep
                    if putIn > 16 {
                        Text("You put in").sans(11, weight: .bold).foregroundStyle(.white)
                    }
                }
                .frame(width: width * Double(putIn) / 100)
                ZStack {
                    theme.gold
                    if growthPct > 16 {
                        Text("Growth").sans(11, weight: .bold).foregroundStyle(Color(hex: "2A2008"))
                    }
                }
            }
        }
        .frame(height: 30)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Growth is \(growthPct) percent of the projected balance")
    }

    private func extraPerPayRow(payFrequency: PayFrequency) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Extra per pay").sans(14, weight: .semibold).foregroundStyle(theme.ink)
                Text("Salary sacrifice, \(payFrequency.label.lowercased())")
                    .sans(12).foregroundStyle(theme.ink3)
            }
            Spacer(minLength: 8)
            HStack(spacing: 12) {
                StepButton(systemImage: "minus", accessibilityLabel: "Decrease extra contribution") {
                    extraPerPay = max(0, extraPerPay - 50)
                }
                Text(DaybreakFormat.money(extraPerPay, fractionDigits: 0))
                    .mono(17, weight: .medium).foregroundStyle(theme.ink)
                    .frame(minWidth: 60)
                StepButton(systemImage: "plus", accessibilityLabel: "Increase extra contribution") {
                    extraPerPay = min(1500, extraPerPay + 50)
                }
            }
        }
        .padding(.vertical, 13).padding(.horizontal, 16)
        .glassCard(cornerRadius: 14)
    }

    @ViewBuilder
    private func impactNote(plan: Plan) -> some View {
        if extraPerPay > 0 {
            VStack(alignment: .leading, spacing: 8) {
                styledText([
                    TextRun(string: "Adding "),
                    TextRun(string: DaybreakFormat.money(extraPerPay, fractionDigits: 0), bold: true),
                    TextRun(string: " per pay grows your super by about "),
                    TextRun(string: DaybreakFormat.big(plan.delta), color: theme.keep, bold: true),
                    TextRun(string: " extra over \(plan.years) years."),
                ])
                .sans(14).foregroundStyle(theme.ink).lineSpacing(2)
                if plan.mine.over {
                    Text("Over the $\(Int(config.concessionalCap / 1000))k concessional cap — modelled to the cap only.")
                        .sans(12, weight: .semibold).foregroundStyle(theme.tax)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16).padding(.horizontal, 18)
            .background(theme.keepSoft, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            Text("Add an amount above to see the impact on your retirement balance.")
                .sans(12.5).foregroundStyle(theme.ink3)
        }
    }

    private func legend(_ lines: [GrowthLine]) -> some View {
        FlowLayout(spacing: 14, rowSpacing: 6) {
            ForEach(lines) { line in
                HStack(spacing: 6) {
                    Capsule().fill(line.color).frame(width: 12, height: 3)
                    Text(line.label + (line.isYou ? " (you)" : "") + "/pay")
                        .sans(12, weight: line.isYou ? .bold : .medium)
                        .foregroundStyle(theme.ink2)
                }
            }
        }
    }

    private func modelTable(plan: Plan) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Per pay").frame(maxWidth: .infinity, alignment: .leading)
                Text("Per year").frame(width: 64, alignment: .trailing)
                Text("At \(plan.years)y").frame(width: 60, alignment: .trailing)
                Text("Extra").frame(width: 60, alignment: .trailing)
            }
            .sans(10.5, weight: .bold).tracking(0.5).textCase(.uppercase)
            .foregroundStyle(theme.ink3)
            .padding(.vertical, 11).padding(.horizontal, 16)
            .background(theme.surface2)

            ForEach(plan.models) { model in
                let isMine = model.perPay == extraPerPay && extraPerPay > 0
                HStack {
                    Text(DaybreakFormat.money(model.perPay, fractionDigits: 0))
                        .sans(13.5, weight: isMine ? .bold : .semibold)
                        .foregroundStyle(model.over ? theme.tax : (isMine ? theme.keep : theme.ink))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(DaybreakFormat.money(model.grossExtra, fractionDigits: 0))
                        .mono(12).foregroundStyle(theme.ink3).frame(width: 64, alignment: .trailing)
                    Text(DaybreakFormat.big(model.balance))
                        .mono(12.5).foregroundStyle(theme.ink).frame(width: 60, alignment: .trailing)
                    Text(model.perPay == 0 ? "—" : "+" + DaybreakFormat.big(model.balance - plan.base0.balance))
                        .mono(12.5).foregroundStyle(theme.keep).frame(width: 60, alignment: .trailing)
                }
                .padding(.vertical, 12).padding(.horizontal, 16)
                .background(isMine ? theme.surface2 : Color.clear)
                .overlay(alignment: .top) { Rectangle().fill(theme.hairline).frame(height: 1) }
            }
        }
        .glassCard()
    }

    private var disclaimer: some View {
        Text("Indicative only. The concessional (before-tax) cap is $\(Int(config.concessionalCap / 1000))k/year including employer super; going over has tax consequences. Growth assumed net of fund earnings tax; ignores fees, wage growth and Division 293 for high earners. Not financial advice.")
            .sans(11.5).foregroundStyle(theme.ink3).lineSpacing(2)
    }
}
