import SwiftUI

/// A small "i" button that reveals an explanatory popover. Mirrors `Info`.
struct InfoButton: View {
    @Environment(\.theme) private var theme
    let text: String
    var dark: Bool = false
    @State private var isPresented = false

    private var tint: Color { dark ? theme.summaryMuted : theme.ink3 }

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Text("i")
                .serif(11, weight: .semibold, relativeTo: .caption2)
                .italic()
                .foregroundStyle(tint)
                .frame(width: 18, height: 18)
                .overlay(Circle().strokeBorder(tint, lineWidth: 1.3))
                // Keep the 18pt visual but give it a 44pt tap target.
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("More information")
        .accessibilityHint(text)
        .popover(isPresented: $isPresented) {
            Text(text)
                .sans(13)
                .foregroundStyle(theme.ink)
                .padding(14)
                .frame(maxWidth: 260)
                .presentationCompactAdaptation(.popover)
        }
    }
}
