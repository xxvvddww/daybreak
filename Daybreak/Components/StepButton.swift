import SwiftUI

/// A round − / + button used by the stepper rows on Setup and Super.
struct StepButton: View {
    @Environment(\.theme) private var theme
    let systemImage: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(theme.ink)
                .frame(width: 34, height: 34)
                .background(theme.surface, in: Circle())
                .overlay(Circle().strokeBorder(theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
