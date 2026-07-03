import SwiftUI

/// A glass row with a label, optional subtitle and a trailing native `Toggle`.
/// Mirrors `Row2` + `Toggle` from the prototype.
struct ToggleRow: View {
    @Environment(\.theme) private var theme
    let label: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .sans(14, weight: .semibold)
                    .foregroundStyle(theme.ink)
                if let subtitle {
                    Text(subtitle)
                        .sans(12)
                        .foregroundStyle(theme.ink3)
                }
            }
            Spacer(minLength: 8)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(theme.keep)
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 16)
        .glassCard(cornerRadius: 14)
        .sensoryFeedback(.selection, trigger: isOn)
        .accessibilityElement(children: .combine)
    }
}

/// A label/value line inside a glass breakdown card. Mirrors `Line`.
struct KeyValueLine: View {
    @Environment(\.theme) private var theme
    let label: String
    let value: String
    var valueColor: Color? = nil
    var bold: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .sans(bold ? 14.5 : 13.5, weight: bold ? .bold : .medium)
                .foregroundStyle(bold ? theme.ink : theme.ink2)
            Spacer(minLength: 8)
            Text(value)
                .mono(bold ? 17 : 14, weight: .medium)
                .foregroundStyle(valueColor ?? theme.ink)
        }
        .padding(.vertical, 9)
        .accessibilityElement(children: .combine)
    }
}

/// A label/value line inside the inverted dark "summary" card. Mirrors `Row`.
struct SummaryRow: View {
    @Environment(\.theme) private var theme
    let label: String
    let value: String
    var valueColor: Color? = nil
    var big: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .sans(big ? 14 : 13)
                .foregroundStyle(theme.summaryMuted)
            Spacer(minLength: 8)
            Text(value)
                .mono(big ? 20 : 15, weight: .medium)
                .foregroundStyle(valueColor ?? theme.summaryText)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

/// A large serif figure with a label and supporting copy, with an optional
/// info popover. Mirrors `StatCard` on the Damage screen.
struct StatCard: View {
    @Environment(\.theme) private var theme
    let bigText: String
    let label: String
    var subMarkdown: String? = nil
    var color: Color? = nil
    var info: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(bigText)
                    .serif(34, weight: .medium, relativeTo: .largeTitle)
                    .foregroundStyle(color ?? theme.ink)
                if let info {
                    Spacer(minLength: 8)
                    InfoButton(text: info)
                }
            }
            Text(label)
                .sans(14.5, weight: .semibold)
                .foregroundStyle(theme.ink)
                .padding(.top, 9)
            if let subMarkdown {
                mdText(subMarkdown)
                    .sans(13)
                    .foregroundStyle(theme.ink2)
                    .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 18)
        .padding(.bottom, 4)
        .overlay(alignment: .top) {
            Rectangle().fill(theme.hairline).frame(height: 1)
        }
        .accessibilityElement(children: .combine)
    }
}
