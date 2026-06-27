import Foundation

/// The payload the app hands to the widget through the shared App Group.
///
/// It carries everything the widget needs to recompute live figures itself
/// (so the timeline stays accurate between refreshes) without any knowledge of
/// SwiftData or the app's view layer.
struct SharedSnapshot: Codable, Equatable, Sendable {
    var inputs: ProfileInputs
    var mode: EarningMode
    var updatedAt: Date

    init(inputs: ProfileInputs, mode: EarningMode, updatedAt: Date) {
        self.inputs = inputs
        self.mode = mode
        self.updatedAt = updatedAt
    }

    /// A sensible placeholder so the widget always renders something, even
    /// before the app has written real data (fresh install, previews, or a
    /// misconfigured App Group).
    static func placeholder(updatedAt: Date) -> SharedSnapshot {
        SharedSnapshot(inputs: ProfileInputs(), mode: .live, updatedAt: updatedAt)
    }
}
