import SwiftUI

/// Builds a `Text` from a markdown string at runtime (so interpolated values
/// can carry **bold** emphasis). `LocalizedStringKey` markdown only works for
/// static literals, hence this `AttributedString`-based helper.
func mdText(_ markdown: String) -> Text {
    let attributed = (try? AttributedString(markdown: markdown)) ?? AttributedString(markdown)
    return Text(attributed)
}

/// A single styled run for ``styledText``.
struct TextRun {
    let string: String
    var color: Color? = nil
    var bold: Bool = false
}

/// Concatenates runs into one `Text`, giving each run an optional colour and
/// bold emphasis. Runs without a colour inherit the surrounding
/// `.foregroundStyle`, and runs without an explicit font inherit the
/// surrounding font (so Dynamic Type still applies). This is how the app draws
/// inline coloured/bold figures inside body copy.
func styledText(_ runs: [TextRun]) -> Text {
    var result = AttributedString()
    for run in runs {
        var piece = AttributedString(run.string)
        if let color = run.color { piece.foregroundColor = color }
        if run.bold { piece.inlinePresentationIntent = .stronglyEmphasized }
        result += piece
    }
    return Text(result)
}
