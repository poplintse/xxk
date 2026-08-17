import Foundation
import Observation

@MainActor
@Observable
final class AppPreferences {
    private enum Key {
        static let lodgingCheckInMinutes = "lodgingCheckInMinutes"
        static let lodgingCheckOutMinutes = "lodgingCheckOutMinutes"
        static let timelineStepMinutes = "timelineStepMinutes"
        static let timelineStartHour = "timelineStartHour"
        static let warnsAboutOverlap = "warnsAboutOverlap"
        static let currencyCode = "currencyCode"
    }

    private let defaults: UserDefaults

    var lodgingCheckInMinutes: Int { didSet { defaults.set(lodgingCheckInMinutes, forKey: Key.lodgingCheckInMinutes) } }
    var lodgingCheckOutMinutes: Int { didSet { defaults.set(lodgingCheckOutMinutes, forKey: Key.lodgingCheckOutMinutes) } }
    var timelineStepMinutes: Int { didSet { defaults.set(timelineStepMinutes, forKey: Key.timelineStepMinutes) } }
    var timelineStartHour: Int { didSet { defaults.set(timelineStartHour, forKey: Key.timelineStartHour) } }
    var warnsAboutOverlap: Bool { didSet { defaults.set(warnsAboutOverlap, forKey: Key.warnsAboutOverlap) } }
    var currencyCode: String { didSet { defaults.set(currencyCode, forKey: Key.currencyCode) } }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.lodgingCheckInMinutes: 23 * 60,
            Key.lodgingCheckOutMinutes: 15 * 60,
            Key.timelineStepMinutes: 15,
            Key.timelineStartHour: 6,
            Key.warnsAboutOverlap: true,
            Key.currencyCode: "CNY"
        ])
        lodgingCheckInMinutes = min(max(defaults.integer(forKey: Key.lodgingCheckInMinutes), 0), 24 * 60 - 1)
        lodgingCheckOutMinutes = min(max(defaults.integer(forKey: Key.lodgingCheckOutMinutes), 0), 24 * 60 - 1)
        let storedStep = defaults.integer(forKey: Key.timelineStepMinutes)
        timelineStepMinutes = [5, 15, 30].contains(storedStep) ? storedStep : 15
        timelineStartHour = min(max(defaults.integer(forKey: Key.timelineStartHour), 0), 23)
        warnsAboutOverlap = defaults.bool(forKey: Key.warnsAboutOverlap)
        let storedCurrency = defaults.string(forKey: Key.currencyCode) ?? "CNY"
        currencyCode = ["CNY", "USD", "EUR", "JPY"].contains(storedCurrency) ? storedCurrency : "CNY"
    }
}
