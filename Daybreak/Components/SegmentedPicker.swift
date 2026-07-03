import SwiftUI

struct SegmentOption<Value: Hashable>: Identifiable {
    let value: Value
    let label: String
    var id: Value { value }
}

/// A pill-shaped segmented control matching the prototype's `Seg`/`AppSeg`.
/// The selection thumb glides between options (matched geometry) rather than
/// jumping. Each option is an accessible button carrying `.isSelected`.
struct SegmentedPicker<Value: Hashable>: View {
    @Environment(\.theme) private var theme
    @Binding var selection: Value
    let options: [SegmentOption<Value>]
    @Namespace private var thumb

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options) { option in
                let isOn = selection == option.value
                Button {
                    withAnimation(.snappy(duration: 0.25)) { selection = option.value }
                } label: {
                    Text(option.label)
                        .sans(12.5, weight: .semibold)
                        .foregroundStyle(isOn ? theme.ink : theme.ink3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background {
                            if isOn {
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .fill(theme.segOn)
                                    .shadow(color: .black.opacity(0.10), radius: 2, y: 1)
                                    .matchedGeometryEffect(id: "thumb", in: thumb)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isOn ? [.isSelected, .isButton] : [.isButton])
            }
        }
        .padding(3)
        .background(theme.seg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .sensoryFeedback(.selection, trigger: selection)
    }
}
