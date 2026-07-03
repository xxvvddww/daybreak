import SwiftUI

/// Seven-day selector (Mon=0 … Sun=6). At least one day must stay selected.
struct DayPicker: View {
    @Environment(\.theme) private var theme
    @Binding var selection: [Int]

    private let shortLabels = ["M", "T", "W", "T", "F", "S", "S"]
    private let fullNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    private func toggle(_ index: Int) {
        var next = selection
        if next.contains(index) {
            next.removeAll { $0 == index }
        } else {
            next.append(index)
        }
        if !next.isEmpty { selection = next.sorted() }
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(shortLabels.indices, id: \.self) { index in
                let isOn = selection.contains(index)
                Button { toggle(index) } label: {
                    Text(shortLabels[index])
                        .sans(14, weight: .bold)
                        .foregroundStyle(isOn ? .white : theme.ink3)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background {
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .fill(isOn ? theme.keep : theme.surface)
                        }
                        .overlay {
                            if !isOn {
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .strokeBorder(theme.hairline, lineWidth: 1)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(fullNames[index])
                .accessibilityAddTraits(isOn ? [.isSelected, .isButton] : [.isButton])
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}
