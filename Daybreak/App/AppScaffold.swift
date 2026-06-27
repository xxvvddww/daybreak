import SwiftUI

/// Hosts the selected feature screen with the custom bottom tab bar pinned via
/// a bottom safe-area inset (so scroll content insets correctly above it).
struct AppScaffold: View {
    @State private var tab: AppTab = .today

    var body: some View {
        currentScreen
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                CustomTabBar(selection: $tab)
            }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch tab {
        case .today: TodayView()
        case .pay: PayView()
        case .superannuation: SuperView()
        case .damage: DamageView()
        case .stats: StatsView()
        case .setup: SetupView()
        }
    }
}

/// A reusable scrolling container for a feature screen, applying the standard
/// horizontal padding and bottom inset.
struct FeatureScreen<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 30)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
    }
}
