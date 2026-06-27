import SwiftUI
import SwiftData

@main
struct DaybreakApp: App {
    let container: ModelContainer

    init() {
        // UI tests launch with `-uitests` for a clean, in-memory, pre-onboarding state.
        let isUITesting = CommandLine.arguments.contains("-uitests")
        if isUITesting {
            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        }
        do {
            // Local, on-device store only — no CloudKit / iCloud sync.
            let configuration = ModelConfiguration(isStoredInMemoryOnly: isUITesting)
            container = try ModelContainer(for: Profile.self, configurations: configuration)
        } catch {
            fatalError("Failed to create the SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
        }
    }
}
