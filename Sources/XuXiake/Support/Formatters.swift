import Foundation

enum AppFormatters {
    static func dayHeader(_ date: Date, timeZone: TimeZone) -> String {
        formatter("E M/d", timeZone: timeZone).string(from: date)
    }

    static func dateTime(_ date: Date, timeZone: TimeZone) -> String {
        formatter("M月d日 HH:mm", timeZone: timeZone).string(from: date)
    }

    static func time(_ date: Date, timeZone: TimeZone) -> String {
        formatter("HH:mm", timeZone: timeZone).string(from: date)
    }

    static func monthTitle(_ date: Date, timeZone: TimeZone) -> String {
        formatter("yyyy年M月", timeZone: timeZone).string(from: date)
    }

    static func dayNumber(_ date: Date, timeZone: TimeZone) -> String {
        formatter("d", timeZone: timeZone).string(from: date)
    }

    static func moneySummary(_ amounts: [(minorUnits: Int, currencyCode: String)]) -> String {
        let totals = Dictionary(grouping: amounts, by: \.currencyCode)
            .mapValues { values in
                values.reduce(0) { partial, value in
                    let (sum, overflow) = partial.addingReportingOverflow(value.minorUnits)
                    if !overflow { return sum }
                    return value.minorUnits >= 0 ? Int.max : Int.min
                }
            }
        guard !totals.isEmpty else { return money(minorUnits: 0, currencyCode: "CNY") }
        return totals.keys.sorted().map { code in
            money(minorUnits: totals[code] ?? 0, currencyCode: code)
        }.joined(separator: " · ")
    }

    private static func formatter(_ dateFormat: String, timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat
        return formatter
    }

    static func money(minorUnits: Int, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: Double(minorUnits) / 100)) ?? "—"
    }

    static func minorUnits(from amount: Double) -> Int {
        guard amount.isFinite, amount > 0 else { return 0 }
        let scaled = amount * 100
        guard scaled < Double(Int.max) else { return Int.max }
        return Int(scaled.rounded())
    }
}
