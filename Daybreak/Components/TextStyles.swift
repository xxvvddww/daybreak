import SwiftUI

/// Large editorial screen title (serif).
struct ScreenTitle: View {
    @Environment(\.theme) private var theme
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .serif(27, weight: .medium, relativeTo: .largeTitle)
            .foregroundStyle(theme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 6)
            .padding(.bottom, 18)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Small uppercase section label.
struct SectionLabel: View {
    @Environment(\.theme) private var theme
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .sans(11, weight: .bold, relativeTo: .caption)
            .tracking(1.2)
            .foregroundStyle(theme.ink3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A labelled section wrapper used on the Setup screen.
struct FieldLabel: View {
    @Environment(\.theme) private var theme
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .sans(11, weight: .bold, relativeTo: .caption)
            .tracking(1.2)
            .foregroundStyle(theme.ink3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
    }
}
