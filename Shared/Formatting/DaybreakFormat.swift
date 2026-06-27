import Foundation

/// Number / time formatting helpers, ported from the prototype's `money`,
/// `big`, `clock` and `hm` helpers. Kept as pure functions so they can be unit
/// tested and reused by both the app and the widget.
enum DaybreakFormat {

    /// A locale-aware currency string. `fractionDigits` controls precision
    /// (the prototype shows 0–4 dp depending on the figure).
    static func money(_ value: Double, fractionDigits: Int = 2, config: CountryConfig = .australia) -> String {
        let formatter = currencyFormatter(fractionDigits: fractionDigits, config: config)
        let safe = value.isFinite ? value : 0
        return formatter.string(from: NSNumber(value: safe)) ?? "$0"
    }

    /// Compact money for large headline figures: `$1.3m`, `$48k`, `$540`.
    ///
    /// Rounding is performed explicitly with `.toNearestOrAwayFromZero` (the
    /// default for `Double.rounded()`) so it matches JavaScript's `Math.round`
    /// / `toFixed` behaviour from the prototype, rather than `printf`'s
    /// round-half-to-even.
    static func big(_ value: Double) -> String {
        let rounded = value.rounded()
        if rounded >= 1_000_000 {
            let millions = rounded / 1_000_000
            if rounded >= 10_000_000 {
                return "$" + String(Int(millions.rounded())) + "m"
            }
            let oneDecimal = (millions * 10).rounded() / 10
            return "$" + String(format: "%.1f", oneDecimal) + "m"
        }
        if rounded >= 1_000 {
            return "$" + String(Int((rounded / 1_000).rounded())) + "k"
        }
        return "$" + String(Int(rounded))
    }

    /// A 12-hour clock string from seconds-since-midnight, e.g. `5:30pm`.
    static func clock(_ seconds: Double) -> String {
        var hour = Int(seconds / 3600) % 24
        if hour < 0 { hour += 24 }
        let minute = (Int(seconds) % 3600) / 60
        let suffix = hour >= 12 ? "pm" : "am"
        var twelve = hour % 12
        if twelve == 0 { twelve = 12 }
        return "\(twelve):\(String(format: "%02d", minute))\(suffix)"
    }

    /// A short duration from seconds, e.g. `3h 12m` or `45m`.
    static func hourMinute(_ seconds: Double) -> String {
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600) / 60).rounded())
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }

    /// A month + day string for the tax-freedom date, e.g. `April 12`.
    static func monthDay(_ date: Date, config: CountryConfig = .australia) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: config.localeIdentifier)
        formatter.setLocalizedDateFormatFromTemplate("MMMMd")
        return formatter.string(from: date)
    }

    // MARK: - Private

    private static func currencyFormatter(fractionDigits: Int, config: CountryConfig) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: config.localeIdentifier)
        formatter.currencyCode = config.currencyCode
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        // Match Intl.NumberFormat's default "round half away from zero".
        formatter.roundingMode = .halfUp
        return formatter
    }
}
