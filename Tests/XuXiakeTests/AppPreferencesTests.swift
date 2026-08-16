import Foundation
import Testing
@testable import XuXiake

@MainActor
struct AppPreferencesTests {
    @Test func invalidStoredValuesFallBackToSafeRuntimeSettings() {
        let suiteName = "AppPreferencesTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(-50, forKey: "lodgingCheckInMinutes")
        defaults.set(9_999, forKey: "lodgingCheckOutMinutes")
        defaults.set(0, forKey: "timelineStepMinutes")
        defaults.set(99, forKey: "timelineStartHour")
        defaults.set("INVALID", forKey: "currencyCode")

        let preferences = AppPreferences(defaults: defaults)

        #expect(preferences.lodgingCheckInMinutes == 0)
        #expect(preferences.lodgingCheckOutMinutes == 24 * 60 - 1)
        #expect(preferences.timelineStepMinutes == 15)
        #expect(preferences.timelineStartHour == 23)
        #expect(preferences.currencyCode == "CNY")
    }
}
