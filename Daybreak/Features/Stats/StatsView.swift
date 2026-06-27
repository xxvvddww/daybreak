import SwiftUI

/// The Stats screen: where the user's income sits nationally and against their
/// state's median.
struct StatsView: View {
    @Environment(\.theme) private var theme
    @Environment(ProfileStore.self) private var store

    @State private var regionCode = "WA"

    private let calculator = EarningsCalculator()
    private let distribution = IncomeDistribution()
    private let config = CountryConfig.australia

    var body: some View {
        let base = calculator.breakdown(for: store.inputs).base
        let percentile = distribution.percentile(income: base)
        let top = max(0.5, 100 - percentile)
        let regionMedian = config.regionMedians.first { $0.code == regionCode }?.median ?? 0
        let vsRegion = distribution.differenceFromRegionMedian(income: base, regionCode: regionCode)

        FeatureScreen {
            ScreenTitle("Where you sit")

            VStack(spacing: 8) {
                Text(percentile >= 50 ? "Top \(Int(top.rounded()))%" : "\(Int(percentile.rounded()))th")
                    .serif(46, weight: .medium, relativeTo: .largeTitle)
                    .foregroundStyle(theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                styledText([
                    TextRun(string: "You earn more than about "),
                    TextRun(string: "\(Int(percentile.rounded()))%", color: theme.ink, bold: true),
                    TextRun(string: " of Australian earners."),
                ])
                .sans(13.5).foregroundStyle(theme.ink2)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 18)

            PercentileBarView(
                percentile: percentile,
                lowAnchorLabel: DaybreakFormat.money(config.distribution[1].income, fractionDigits: 0),
                highAnchorLabel: DaybreakFormat.money(config.distribution.last?.income ?? 0, fractionDigits: 0) + "+"
            )
            .padding(.bottom, 18)

            SectionLabel("Compared to your state")
            regionPicker.padding(.bottom, 12)

            styledText([
                TextRun(string: "\(regionCode)'s median personal income is about "),
                TextRun(string: DaybreakFormat.money(regionMedian, fractionDigits: 0), bold: true),
                TextRun(string: ". You earn "),
                TextRun(string: "\(abs(Int(vsRegion.rounded())))% \(vsRegion >= 0 ? "above" : "below")",
                        color: vsRegion >= 0 ? theme.keep : theme.tax, bold: true),
                TextRun(string: " that."),
            ])
            .sans(14).foregroundStyle(theme.ink).lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16).padding(.horizontal, 18)
            .glassCard()
            .padding(.bottom, 14)

            regionTable

            Text("Indicative only, based on approximate income distribution data. Personal income excludes employer super.")
                .sans(11.5).foregroundStyle(theme.ink3).lineSpacing(2)
                .padding(.top, 14)
        }
    }

    private var regionPicker: some View {
        Menu {
            Picker("State or territory", selection: $regionCode) {
                ForEach(config.regionMedians) { region in
                    Text(region.code).tag(region.code)
                }
            }
        } label: {
            HStack {
                Text(regionCode)
                    .sans(15, weight: .semibold)
                    .foregroundStyle(theme.ink)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 12))
                    .foregroundStyle(theme.ink3)
            }
            .padding(.vertical, 12).padding(.horizontal, 14)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(theme.hairline, lineWidth: 1))
        }
        .accessibilityLabel("State or territory")
        .accessibilityValue(regionCode)
    }

    private var regionTable: some View {
        VStack(spacing: 0) {
            ForEach(Array(distribution.regionsByMedianDescending.enumerated()), id: \.element.code) { index, region in
                let isSelected = region.code == regionCode
                Button {
                    regionCode = region.code
                } label: {
                    HStack {
                        Text(region.code)
                            .sans(14, weight: isSelected ? .bold : .semibold)
                            .foregroundStyle(isSelected ? theme.keep : theme.ink)
                        Spacer()
                        Text(DaybreakFormat.money(region.median, fractionDigits: 0))
                            .mono(13.5).foregroundStyle(theme.ink3)
                    }
                    .padding(.vertical, 12).padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? theme.surface2 : Color.clear)
                    .overlay(alignment: .top) {
                        if index > 0 { Rectangle().fill(theme.hairline).frame(height: 1) }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(region.code), median \(DaybreakFormat.money(region.median, fractionDigits: 0))")
                .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : [.isButton])
            }
        }
        .glassCard()
    }
}
