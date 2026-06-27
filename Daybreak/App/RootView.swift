import SwiftUI
import SwiftData

/// The top of the view tree: resolves the theme, builds the `ProfileStore` from
/// the SwiftData context, and gates onboarding.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var systemScheme
    @AppStorage("themePreference") private var themeRaw = ThemePreference.system.rawValue
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var store: ProfileStore?

    private var preference: ThemePreference { ThemePreference(rawValue: themeRaw) ?? .system }
    private var theme: Theme { Theme.resolved(for: preference.resolvedScheme(system: systemScheme)) }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            if let store {
                if hasCompletedOnboarding {
                    AppScaffold()
                        .environment(store)
                        .transition(.opacity)
                } else {
                    OnboardingView {
                        withAnimation(.easeInOut) { hasCompletedOnboarding = true }
                    }
                    .environment(store)
                    .transition(.opacity)
                }
            }
        }
        .environment(\.theme, theme)
        .preferredColorScheme(preference.colorScheme)
        .tint(theme.keep)
        .task {
            if store == nil {
                store = ProfileStore(context: modelContext)
            }
        }
    }
}
