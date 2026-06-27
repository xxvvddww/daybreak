import Foundation
import SwiftUI
import SwiftData
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Owns the user's editable state and all of its side effects.
///
/// Reads happen through `inputs` / `mode`; writes flow back to SwiftData and to
/// the App Group snapshot the widget consumes, and trigger a widget reload. The
/// engine never touches this type — it only ever sees `ProfileInputs` — which
/// keeps the maths pure and this class the single place persistence lives.
@MainActor
@Observable
final class ProfileStore {
    /// The user's financial inputs. Mutating this persists everywhere.
    var inputs: ProfileInputs {
        didSet { guard inputs != oldValue else { return }; commit() }
    }

    /// Live vs. demo. Shared with the widget, so it lives here rather than in
    /// `@AppStorage`.
    var mode: EarningMode {
        didSet { guard mode != oldValue else { return }; commit() }
    }

    private let context: ModelContext
    private let profile: Profile
    private var reloadTask: Task<Void, Never>?

    init(context: ModelContext) {
        self.context = context
        self.profile = Self.fetchOrCreateProfile(in: context)
        self.inputs = profile.inputs
        self.mode = SharedStore.load()?.mode ?? .live
        // Make sure the widget has a snapshot from first launch.
        writeSnapshot()
    }

    /// An ergonomic two-way binding into a single field of `inputs`.
    func binding<Value>(_ keyPath: WritableKeyPath<ProfileInputs, Value>) -> Binding<Value> {
        Binding(
            get: { self.inputs[keyPath: keyPath] },
            set: { self.inputs[keyPath: keyPath] = $0 }
        )
    }

    // MARK: - Persistence

    private func commit() {
        profile.inputs = inputs
        try? context.save()
        writeSnapshot()
    }

    private func writeSnapshot() {
        // The snapshot itself is cheap (App Group UserDefaults) and is written
        // immediately so the widget always has fresh data. The widget reload is
        // debounced so dragging a slider doesn't reload timelines on every tick.
        SharedStore.save(SharedSnapshot(inputs: inputs, mode: mode, updatedAt: .now))
        #if canImport(WidgetKit)
        reloadTask?.cancel()
        reloadTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard self != nil, !Task.isCancelled else { return }
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }

    private static func fetchOrCreateProfile(in context: ModelContext) -> Profile {
        var descriptor = FetchDescriptor<Profile>(sortBy: [SortDescriptor(\.createdAt)])
        descriptor.fetchLimit = 1
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let created = Profile()
        context.insert(created)
        try? context.save()
        return created
    }
}
