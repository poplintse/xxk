import Foundation
import Testing
@testable import XuXiake

struct FormatterTests {
    @Test func travelTimeZoneControlsDisplayedDateAndTime() {
        let instant = Date(timeIntervalSince1970: 0)
        let shanghai = TimeZone(identifier: "Asia/Shanghai")!
        let losAngeles = TimeZone(identifier: "America/Los_Angeles")!

        #expect(AppFormatters.dateTime(instant, timeZone: shanghai) == "1月1日 08:00")
        #expect(AppFormatters.dateTime(instant, timeZone: losAngeles) == "12月31日 16:00")
    }

    @Test func mixedCurrenciesProduceSeparateTotals() {
        let summary = AppFormatters.moneySummary([
            (minorUnits: 12_500, currencyCode: "CNY"),
            (minorUnits: 2_500, currencyCode: "CNY"),
            (minorUnits: 5_000, currencyCode: "USD")
        ])

        #expect(summary.split(separator: "·").count == 2)
        #expect(summary.contains("150"))
        #expect(summary.contains("50"))
    }

    @Test func monetaryInputHandlesNegativeAndExtremeValuesSafely() {
        #expect(AppFormatters.minorUnits(from: 123.456) == 12_346)
        #expect(AppFormatters.minorUnits(from: -1) == 0)
        #expect(AppFormatters.minorUnits(from: .infinity) == 0)
        #expect(AppFormatters.minorUnits(from: Double.greatestFiniteMagnitude) == Int.max)
        #expect(!AppFormatters.moneySummary([
            (minorUnits: Int.max, currencyCode: "CNY"),
            (minorUnits: Int.max, currencyCode: "CNY")
        ]).isEmpty)
    }
}
