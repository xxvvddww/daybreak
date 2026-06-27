import SwiftUI

/// A rounded pill used for "what tax could buy" items.
struct Chip: View {
    @Environment(\.theme) private var theme
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .sans(13, weight: .semibold)
            .foregroundStyle(theme.chipText)
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background(theme.chip, in: Capsule())
    }
}
