import SwiftUI

/// The six-item bottom tab bar, floating above the content as a capsule of
/// Liquid Glass (iOS 26+), with an ultra-thin-material fallback on earlier
/// systems. Built custom rather than with `TabView` because six destinations
/// exceed the system tab bar's comfortable limit and to match the app's
/// iconography. Each item is an accessible, selectable button.
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
                            .symbolVariant(isOn ? .fill : .none)
                        Text(tab.label)
                            .sans(9.5, weight: .semibold)
                            .foregroundStyle(isOn ? (tab.usesTaxAccent ? theme.tax : theme.ink) : theme.tabOff)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.label)
                .accessibilityAddTraits(isOn ? [.isSelected, .isButton] : [.isButton])
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .barChrome(theme)
        .padding(.horizontal, 14)
        .padding(.bottom, 2)
        .sensoryFeedback(.selection, trigger: selection)
    }
}

private extension View {
    /// Liquid Glass capsule where available; material capsule elsewhere.
    @ViewBuilder
    func barChrome(_ theme: Theme) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            legacyBarChrome(theme)
        }
        #else
        legacyBarChrome(theme)
        #endif
    }

    func legacyBarChrome(_ theme: Theme) -> some View {
        background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(theme.glassBorder, lineWidth: 1))
            .shadow(color: .black.opacity(0.16), radius: 16, x: 0, y: 8)
    }
}
