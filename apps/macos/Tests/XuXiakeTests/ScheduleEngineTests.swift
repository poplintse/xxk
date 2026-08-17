import Foundation
import Testing
@testable import XuXiake

@MainActor
struct ScheduleEngineTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    @Test func snapsToNearestStep() {
        #expect(ScheduleEngine.snap(68, step: 15) == 75)
        #expect(ScheduleEngine.snap(63, step: 15) == 60)
        #expect(ScheduleEngine.snap(24 * 60 - 1, step: 15) == 24 * 60 - 15)
    }

    @Test func lodgingUsesConfiguredCheckInAndCheckout() {
        let suiteName = "ScheduleEngineTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let preferences = AppPreferences(defaults: defaults)
        preferences.lodgingCheckInMinutes = 23 * 60
        preferences.lodgingCheckOutMinutes = 15 * 60
        let item = TripItem(title: "酒店", kind: .lodging, lodgingNights: 3)
        let day = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12))!

        ScheduleEngine.schedule(item, on: day, minute: 0, calendar: calendar, preferences: preferences)

        #expect(item.plannedStart == calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 23)))
        #expect(item.plannedEnd == calendar.date(from: DateComponents(year: 2026, month: 10, day: 15, hour: 15)))
        #expect(item.estimatedMinutes == 64 * 60)
    }

    @Test func manuallyAdjustedLodgingKeepsItsDurationWhenMoved() {
        let suiteName = "ScheduleEngineTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let preferences = AppPreferences(defaults: defaults)
        let item = TripItem(
            title: "民宿",
            kind: .lodging,
            estimatedMinutes: 35 * 60 + 30,
            usesDefaultLodgingTime: false
        )
        let targetDay = calendar.date(from: DateComponents(year: 2026, month: 10, day: 20))!

        ScheduleEngine.schedule(item, on: targetDay, minute: 8 * 60, calendar: calendar, preferences: preferences)

        #expect(item.plannedStart == calendar.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 8)))
        #expect(item.plannedEnd == calendar.date(from: DateComponents(year: 2026, month: 10, day: 21, hour: 19, minute: 30)))
        #expect(item.usesDefaultLodgingTime == false)
    }

    @Test func shiftedTimelineDropMapsAfterMidnightToTheNextDay() {
        let visibleDay = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12))!

        let target = ScheduleEngine.dropTarget(
            on: visibleDay,
            minuteFromVisibleStart: 19 * 60,
            startHour: 6,
            calendar: calendar
        )

        #expect(target.day == calendar.date(from: DateComponents(year: 2026, month: 10, day: 13)))
        #expect(target.minute == 60)
    }

    @Test func multiDayItemProducesClippedDailySegments() {
        let item = TripItem(title: "酒店", kind: .lodging)
        item.plannedStart = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 23))
        item.plannedEnd = calendar.date(from: DateComponents(year: 2026, month: 10, day: 15, hour: 15))
        let middleDay = calendar.date(from: DateComponents(year: 2026, month: 10, day: 13))!

        let segment = ScheduleEngine.segment(for: item, on: middleDay, calendar: calendar)

        #expect(segment?.startMinute == 0)
        #expect(segment?.endMinute == 24 * 60)
        #expect(segment?.continuesBefore == true)
        #expect(segment?.continuesAfter == true)
    }

    @Test func shiftedTimelineTreatsMidnightAsLaterOnTheSameVisibleDay() {
        let item = TripItem(title: "夜游", kind: .attraction)
        item.plannedStart = calendar.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: 1))
        item.plannedEnd = calendar.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: 2))
        let visibleDay = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12))!

        let segment = ScheduleEngine.timelineSegment(for: item, on: visibleDay, startHour: 6, calendar: calendar)

        #expect(segment?.startMinute == 19 * 60)
        #expect(segment?.endMinute == 20 * 60)
    }

    @Test func resizeSnapsAndKeepsPositiveDuration() {
        let item = TripItem(title: "参观", kind: .attraction, estimatedMinutes: 120)
        item.plannedStart = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 9))
        item.plannedEnd = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 11))

        ScheduleEngine.resize(item, edge: .end, deltaMinutes: -113, step: 15)

        #expect(item.plannedEnd == calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 9, minute: 15)))
        #expect(item.estimatedMinutes == 15)
    }

    @Test func resizingLodgingRecordsManualDurationForFutureMoves() {
        let item = TripItem(title: "酒店", kind: .lodging, lodgingNights: 2)
        item.plannedStart = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 23))
        item.plannedEnd = calendar.date(from: DateComponents(year: 2026, month: 10, day: 14, hour: 15))

        ScheduleEngine.resize(item, edge: .end, deltaMinutes: 60, step: 15)

        #expect(item.usesDefaultLodgingTime == false)
        #expect(item.estimatedMinutes == 41 * 60)
    }

    @Test func movingScheduledItemSnapsOffsetAndPreservesItsTimeSpan() {
        let item = TripItem(title: "夜游", kind: .attraction)
        item.plannedStart = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 23))
        item.plannedEnd = calendar.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: 2, minute: 30))

        ScheduleEngine.move(item, dayDelta: 1, minuteDelta: -22, step: 15, calendar: calendar)

        #expect(item.plannedStart == calendar.date(from: DateComponents(year: 2026, month: 10, day: 13, hour: 22, minute: 45)))
        #expect(item.plannedEnd == calendar.date(from: DateComponents(year: 2026, month: 10, day: 14, hour: 2, minute: 15)))
        #expect(item.estimatedMinutes == 210)
    }

    @Test func movingDefaultLodgingByWholeDaysPreservesLocalTimesAcrossDST() {
        var daylightSavingCalendar = Calendar(identifier: .gregorian)
        daylightSavingCalendar.timeZone = TimeZone(identifier: "America/New_York")!
        let item = TripItem(title: "酒店", kind: .lodging, usesDefaultLodgingTime: true)
        item.plannedStart = daylightSavingCalendar.date(from: DateComponents(year: 2026, month: 3, day: 7, hour: 23))
        item.plannedEnd = daylightSavingCalendar.date(from: DateComponents(year: 2026, month: 3, day: 8, hour: 15))

        ScheduleEngine.move(item, dayDelta: 1, minuteDelta: 0, step: 15, calendar: daylightSavingCalendar)

        #expect(item.plannedStart == daylightSavingCalendar.date(from: DateComponents(year: 2026, month: 3, day: 8, hour: 23)))
        #expect(item.plannedEnd == daylightSavingCalendar.date(from: DateComponents(year: 2026, month: 3, day: 9, hour: 15)))
        #expect(item.usesDefaultLodgingTime == true)
    }

    @Test func movingDefaultLodgingVerticallyCreatesAManualSchedule() {
        let item = TripItem(title: "酒店", kind: .lodging, usesDefaultLodgingTime: true)
        item.plannedStart = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 23))
        item.plannedEnd = calendar.date(from: DateComponents(year: 2026, month: 10, day: 14, hour: 15))

        ScheduleEngine.move(item, dayDelta: 0, minuteDelta: 30, step: 15, calendar: calendar)

        #expect(item.plannedStart == calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 23, minute: 30)))
        #expect(item.plannedEnd == calendar.date(from: DateComponents(year: 2026, month: 10, day: 14, hour: 15, minute: 30)))
        #expect(item.usesDefaultLodgingTime == false)
    }

    @Test func conflictDetectionMarksBothIntersectingItems() {
        let first = TripItem(title: "A", kind: .attraction)
        first.plannedStart = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 9))
        first.plannedEnd = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 11))
        let second = TripItem(title: "B", kind: .dining)
        second.plannedStart = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 10))
        second.plannedEnd = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 12))
        let third = TripItem(title: "C", kind: .shopping)
        third.plannedStart = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 13))
        third.plannedEnd = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12, hour: 14))

        let conflicts = ScheduleEngine.conflictingItemIDs(in: [first, second, third])

        #expect(conflicts == [first.id, second.id])
    }

    @Test func largePlanConflictScanRemainsCorrect() {
        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let items = (0..<1_000).map { index in
            let item = TripItem(title: "事项 \(index)", kind: .other)
            item.plannedStart = start.addingTimeInterval(TimeInterval(index * 30 * 60))
            item.plannedEnd = start.addingTimeInterval(TimeInterval((index * 30 + 15) * 60))
            return item
        }

        #expect(ScheduleEngine.conflictingItemIDs(in: items).isEmpty)
    }

    @Test func heavilyOverlappingPlanMarksEveryItem() {
        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let items = (0..<10_000).map { index in
            let item = TripItem(title: "重叠事项 \(index)", kind: .other)
            item.plannedStart = start.addingTimeInterval(TimeInterval(index))
            item.plannedEnd = start.addingTimeInterval(24 * 60 * 60)
            return item
        }

        #expect(ScheduleEngine.conflictingItemIDs(in: items).count == items.count)
    }
}
