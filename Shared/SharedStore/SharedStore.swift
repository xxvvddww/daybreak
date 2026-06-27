import Foundation

/// Reads and writes the `SharedSnapshot` in the App Group container shared
/// between the app and the widget extension.
///
/// All persistence is local to the device (App Group `UserDefaults`); nothing
/// leaves the phone. If the App Group is not configured the store falls back to
/// `.standard` so the app keeps working — the widget simply won't receive
/// cross-process updates until the group is set up. See README for setup.
enum SharedStore {
    /// Must match the App Group capability on both the app and widget targets.
    static let appGroupID = "group.au.com.tsagroup.daybreak"
    static let snapshotKey = "daybreak.snapshot.v1"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static func save(_ snapshot: SharedSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
    }

    static func load() -> SharedSnapshot? {
        guard let data = defaults.data(forKey: snapshotKey) else { return nil }
        return try? JSONDecoder().decode(SharedSnapshot.self, from: data)
    }
}
