import SwiftUI

/// A labelled time row backed by a native `DatePicker` (fully accessible),
/// bridging between the engine's "hours since midnight" `Double` and a `Date`.
struct TimeField: View {
    @Environment(\.theme) private var theme
    let title: String
    @Binding var hour: Double

    private var dateBinding: Binding<Date> {
        Binding(
            get: {
                let totalMinutes = Int((hour * 60).rounded())
                let h = ((totalMinutes / 60) % 24 + 24) % 24
                let m = ((totalMinutes % 60) + 60) % 60
                return Calendar.current.date(from: DateComponents(hour: h, minute: m)) ?? Date()
            },
            set: { newValue in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                hour = Double(comps.hour ?? 0) + Double(comps.minute ?? 0) / 60
            }
        )
    }

    var body: some View {
        HStack {
            Text(title)
                .sans(14, weight: .semibold)
                .foregroundStyle(theme.ink)
            Spacer(minLength: 8)
            DatePicker("", selection: dateBinding, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .glassCard(cornerRadius: 14)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }
}
