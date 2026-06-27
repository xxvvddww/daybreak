import SwiftUI

/// The Setup screen: every input that drives the app, plus appearance and the
/// live/demo mode switch. Bindings flow straight into the `ProfileStore`, which
/// persists them and refreshes the widget.
struct SetupView: View {
    @Environment(\.theme) private var theme
    @Environment(ProfileStore.self) private var store
    @AppStorage("themePreference") private var themeRaw = ThemePreference.system.rawValue

    private let calculator = EarningsCalculator()
    private let config = CountryConfig.australia

    var body: some View {
        let breakdown = calculator.breakdown(for: store.inputs)

        FeatureScreen {
            ScreenTitle("Setup")

            salarySection
            superSection

            ToggleRow(label: "Medicare levy",
                      subtitle: "Adds 2% on income over ~$27,222",
                      isOn: store.binding(\.medicareLevy))
                .padding(.bottom, 16)

            FieldLabel("Pay frequency")
            SegmentedPicker(selection: store.binding(\.payFrequency), options: PayFrequency.allCases.map {
                SegmentOption(value: $0, label: $0.label)
            })
            .padding(.bottom, 20)

            workingDaySection(breakdown: breakdown)
            displaySection

            summaryCard(breakdown: breakdown)
        }
    }

    // MARK: - Salary

    private var salarySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            FieldLabel("Annual salary")
            Text(DaybreakFormat.money(store.inputs.salary, fractionDigits: 0))
                .mono(28, weight: .medium, relativeTo: .title)
                .foregroundStyle(theme.ink)
            Slider(value: store.binding(\.salary), in: 0...config.maxSalary, step: 1000)
                .tint(theme.keep)
                .padding(.top, 8)
                .accessibilityLabel("Annual salary")
                .accessibilityValue(DaybreakFormat.money(store.inputs.salary, fractionDigits: 0))
        }
        .padding(.bottom, 20)
    }

    // MARK: - Super

    private var superSection: some View {
        VStack(spacing: 10) {
            ToggleRow(
                label: "Salary includes super?",
                subtitle: store.inputs.salaryIncludesSuper ? "Super is backed out of your figure" : "Super is added on top",
                isOn: store.binding(\.salaryIncludesSuper)
            )
            if !store.inputs.salaryIncludesSuper {
                stepperRow(
                    title: "Super rate",
                    value: store.inputs.superRatePercent.formatted(.number.precision(.fractionLength(0...1))) + "%",
                    onDecrement: { store.inputs.superRatePercent = max(0, store.inputs.superRatePercent - 0.5) },
                    onIncrement: { store.inputs.superRatePercent = min(25, store.inputs.superRatePercent + 0.5) },
                    decrementLabel: "Decrease super rate",
                    incrementLabel: "Increase super rate"
                )
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Working day

    private func workingDaySection(breakdown: EarningsBreakdown) -> some View {
        let weekly = (breakdown.weeklyHours * 10).rounded() / 10
        return VStack(alignment: .leading, spacing: 0) {
            FieldLabel("Your working day")
            VStack(spacing: 10) {
                TimeField(title: "Start", hour: store.binding(\.startHour))
                TimeField(title: "Finish", hour: store.binding(\.endHour))
            }

            Text("Days you work")
                .sans(13, weight: .semibold).foregroundStyle(theme.ink2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16).padding(.bottom, 9)
            DayPicker(selection: store.binding(\.workDays))

            VStack(spacing: 10) {
                ToggleRow(
                    label: "Unpaid lunch break",
                    subtitle: store.inputs.hasBreak ? "Subtracted from paid hours" : "No break — full shift is paid",
                    isOn: store.binding(\.hasBreak)
                )
                if store.inputs.hasBreak {
                    stepperRow(
                        title: "Break length",
                        value: "\(store.inputs.breakMinutes) min",
                        onDecrement: { store.inputs.breakMinutes = max(0, store.inputs.breakMinutes - 1) },
                        onIncrement: { store.inputs.breakMinutes = min(180, store.inputs.breakMinutes + 1) },
                        decrementLabel: "Decrease break length",
                        incrementLabel: "Increase break length"
                    )
                }
            }
            .padding(.top, 14)

            HStack {
                Text("You work").foregroundStyle(theme.ink2)
                Spacer()
                styledText([
                    TextRun(string: "\(weekly.formatted(.number.precision(.fractionLength(0...1))))h", bold: true),
                    TextRun(string: " / week"),
                    TextRun(string: "  · \(String(format: "%.1f", breakdown.paidHours))h × \(store.inputs.workDays.count) days", color: theme.ink3),
                ])
            }
            .sans(13.5).foregroundStyle(theme.ink)
            .padding(.vertical, 13).padding(.horizontal, 16)
            .background(theme.surface2, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.top, 14)
        }
        .padding(.bottom, 20)
    }

    // MARK: - Display

    private var displaySection: some View {
        let demoBinding = Binding(
            get: { store.mode == .demo },
            set: { store.mode = $0 ? .demo : .live }
        )
        return VStack(alignment: .leading, spacing: 10) {
            FieldLabel("Appearance")
            SegmentedPicker(selection: $themeRaw, options: ThemePreference.allCases.map {
                SegmentOption(value: $0.rawValue, label: $0.label)
            })
            ToggleRow(
                label: "Demo mode",
                subtitle: "Cycle a sample day in fast-forward",
                isOn: demoBinding
            )
            .padding(.top, 4)
        }
        .padding(.bottom, 20)
    }

    private func summaryCard(breakdown b: EarningsBreakdown) -> some View {
        VStack(spacing: 0) {
            SummaryRow(label: "Gross per year", value: DaybreakFormat.money(store.inputs.salary, fractionDigits: 0))
            SummaryRow(label: "Tax (\(String(format: "%.1f", b.effectiveRate * 100))%)",
                       value: "− " + DaybreakFormat.money(b.tax, fractionDigits: 0),
                       valueColor: theme.tax)
            Rectangle().fill(theme.summaryLine).frame(height: 1).padding(.vertical, 10)
            SummaryRow(label: "Take-home", value: DaybreakFormat.money(b.net, fractionDigits: 0),
                       valueColor: theme.keep, big: true)
        }
        .padding(.vertical, 18).padding(.horizontal, 20)
        .background(theme.summary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Helpers

    private func stepperRow(
        title: String, value: String,
        onDecrement: @escaping () -> Void, onIncrement: @escaping () -> Void,
        decrementLabel: String, incrementLabel: String
    ) -> some View {
        HStack {
            Text(title).sans(14, weight: .semibold).foregroundStyle(theme.ink)
            Spacer()
            HStack(spacing: 14) {
                StepButton(systemImage: "minus", accessibilityLabel: decrementLabel, action: onDecrement)
                Text(value)
                    .mono(16, weight: .medium).foregroundStyle(theme.ink)
                    .frame(minWidth: 56)
                StepButton(systemImage: "plus", accessibilityLabel: incrementLabel, action: onIncrement)
            }
        }
        .padding(.vertical, 10).padding(.horizontal, 16)
        .glassCard(cornerRadius: 14)
    }
}
