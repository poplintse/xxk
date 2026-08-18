import Foundation
import Testing
@testable import XuXiake

struct AppVersionInfoTests {
    @Test func formatsVersionBuildAndTimestamp() {
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: DateComponents(timeZone: TimeZone(secondsFromGMT: 0), year: 2026, month: 8, day: 18, hour: 16, minute: 53))!

        let display = AppVersionInfo.displayString(
            version: "0.2.0",
            build: "9",
            date: date,
            timeZone: TimeZone(secondsFromGMT: 0)!
        )

        #expect(display == "v0.2.0 build 9（08181653）")
    }
}
