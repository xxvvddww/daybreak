import SwiftUI

/// The six-item bottom tab bar. Built custom (rather than `TabView`) because
/// six destinations exceed the system tab bar's comfortable limit, and to match
/// the prototype's iconography. Each item is an accessible, selectable button.
struct CustomTabBar: View {
    @Environment(\.theme) private var theme
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let isOn = selection == tab
                let accent = tab.usesTaxAccent ? theme.tax : theme.keep
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 19))
                            .frame(height: 22)
                            .foregroundStyle(isOn ? accent : theme.tabOff)
                        Text(tab.label)
                            .sans(9.5, weight: .semibold)
                            .foregroundStyle(isOn ? (tab.usesTaxAccent ? theme.tax : theme.ink) : theme.tabOff)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 9)
                    .padding(.bottom, 2)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.label)
                .accessibilityAddTraits(isOn ? [.isSelected, .isButton] : [.isButton])
            }
        }
        .background(.thinMaterial, ignoresSafeAreaEdges: .bottom)
        .overlay(alignment: .top) {
            Rectangle().fill(theme.hairline).frame(height: 1)
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}
