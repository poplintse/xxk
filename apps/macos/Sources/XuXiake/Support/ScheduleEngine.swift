import Foundation

struct ScheduleSegment: Identifiable, Equatable {
    let itemID: UUID
    let day: Date
    let startMinute: Int
    let endMinute: Int
    let continuesBefore: Bool
    let continuesAfter: Bool

    var id: String { "\(itemID.uuidString)-\(day.timeIntervalSinceReferenceDate)" }
}

enum ScheduleResizeEdge {
    case start
    case end
}

enum ScheduleEngine {
    @MainActor
    static func schedule(
        _ item: TripItem,
        on day: Date,
        minute: Int,
        calendar: Calendar,
        preferences: AppPreferences
    ) {
        let dayStart = calendar.startOfDay(for: day)
        if item.kind == .lodging {
            let startMinute = item.usesDefaultLodgingTime
                ? preferences.lodgingCheckInMinutes
                : snap(minute, step: preferences.timelineStepMinutes)
            let start = calendar.date(byAdding: .minute, value: startMinute, to: dayStart) ?? dayStart
            let end: Date
            if item.usesDefaultLodgingTime {
                let checkoutDay = calendar.date(byAdding: .day, value: max(item.lodgingNights, 1), to: dayStart) ?? dayStart
                end = calendar.date(byAdding: .minute, value: preferences.lodgingCheckOutMinutes, to: checkoutDay) ?? checkoutDay
            } else {
                end = calendar.date(
                    byAdding: .minute,
                    value: max(item.estimatedMinutes, preferences.timelineStepMinutes),
                    to: start
                ) ?? start
            }
            item.plannedStart = start
            item.plannedEnd = end
            item.estimatedMinutes = max(Int(end.timeIntervalSince(start) / 60), preferences.timelineStepMinutes)
        } else {
            let snappedMinute = snap(minute, step: preferences.timelineStepMinutes)
            let start = calendar.date(byAdding: .minute, value: snappedMinute, to: dayStart) ?? dayStart
            item.plannedStart = start
            item.plannedEnd = calendar.date(byAdding: .minute, value: max(item.estimatedMinutes, preferences.timelineStepMinutes), to: start)
        }
    }

    static func segment(for item: TripItem, on day: Date, calendar: Calendar) -> ScheduleSegment? {
        guard let start = item.plannedStart, let end = item.plannedEnd, end > start else { return nil }
        let dayStart = calendar.startOfDay(for: day)
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayStart), start < nextDay, end > dayStart else { return nil }

        let clippedStart = max(start, dayStart)
        let clippedEnd = min(end, nextDay)
        let startMinute = max(0, calendar.dateComponents([.minute], from: dayStart, to: clippedStart).minute ?? 0)
        let endMinute = min(24 * 60, calendar.dateComponents([.minute], from: dayStart, to: clippedEnd).minute ?? 24 * 60)

        return ScheduleSegment(
            itemID: item.id,
            day: dayStart,
            startMinute: startMinute,
            endMinute: max(endMinute, startMinute + 1),
            continuesBefore: start < dayStart,
            continuesAfter: end > nextDay
        )
    }

    static func timelineSegment(
        for item: TripItem,
        on day: Date,
        startHour: Int,
        calendar: Calendar
    ) -> ScheduleSegment? {
        guard let start = item.plannedStart, let end = item.plannedEnd, end > start else { return nil }
        let dayStart = calendar.startOfDay(for: day)
        guard let visibleStart = calendar.date(byAdding: .hour, value: startHour, to: dayStart),
              let visibleEnd = calendar.date(byAdding: .day, value: 1, to: visibleStart),
              start < visibleEnd, end > visibleStart else { return nil }

        let clippedStart = max(start, visibleStart)
        let clippedEnd = min(end, visibleEnd)
        let startMinute = max(0, calendar.dateComponents([.minute], from: visibleStart, to: clippedStart).minute ?? 0)
        let endMinute = min(24 * 60, calendar.dateComponents([.minute], from: visibleStart, to: clippedEnd).minute ?? 24 * 60)

        return ScheduleSegment(
            itemID: item.id,
            day: dayStart,
            startMinute: startMinute,
            endMinute: max(endMinute, startMinute + 1),
            continuesBefore: start < visibleStart,
            continuesAfter: end > visibleEnd
        )
    }

    static func snap(_ minute: Int, step: Int) -> Int {
        let safeStep = max(step, 1)
        let clamped = min(max(minute, 0), 24 * 60 - safeStep)
        let snapped = Int((Double(clamped) / Double(safeStep)).rounded()) * safeStep
        return min(snapped, 24 * 60 - safeStep)
    }

    static func dropTarget(
        on visibleDay: Date,
        minuteFromVisibleStart: Int,
        startHour: Int,
        calendar: Calendar
    ) -> (day: Date, minute: Int) {
        let clampedVisibleMinute = min(max(minuteFromVisibleStart, 0), 24 * 60 - 1)
        let safeStartHour = min(max(startHour, 0), 23)
        let absoluteMinute = safeStartHour * 60 + clampedVisibleMinute
        let dayOffset = absoluteMinute / (24 * 60)
        let targetDay = calendar.date(byAdding: .day, value: dayOffset, to: visibleDay) ?? visibleDay
        return (calendar.startOfDay(for: targetDay), absoluteMinute % (24 * 60))
    }

    static func resize(
        _ item: TripItem,
        edge: ScheduleResizeEdge,
        deltaMinutes: Int,
        step: Int
    ) {
        guard let start = item.plannedStart, let end = item.plannedEnd else { return }
        let safeStep = max(step, 1)
        let snappedDelta = Int((Double(deltaMinutes) / Double(safeStep)).rounded()) * safeStep

        switch edge {
        case .start:
            let latestStart = end.addingTimeInterval(TimeInterval(-safeStep * 60))
            item.plannedStart = min(start.addingTimeInterval(TimeInterval(snappedDelta * 60)), latestStart)
        case .end:
            let earliestEnd = start.addingTimeInterval(TimeInterval(safeStep * 60))
            item.plannedEnd = max(end.addingTimeInterval(TimeInterval(snappedDelta * 60)), earliestEnd)
        }

        item.usesDefaultLodgingTime = false
        if let updatedStart = item.plannedStart, let updatedEnd = item.plannedEnd {
            item.estimatedMinutes = max(Int(updatedEnd.timeIntervalSince(updatedStart) / 60), safeStep)
        }
    }

    static func move(
        _ item: TripItem,
        dayDelta: Int,
        minuteDelta: Int,
        step: Int,
        calendar: Calendar
    ) {
        guard let start = item.plannedStart, let end = item.plannedEnd, end > start else { return }
        let safeStep = max(step, 1)
        let snappedMinuteDelta = Int((Double(minuteDelta) / Double(safeStep)).rounded()) * safeStep
        guard dayDelta != 0 || snappedMinuteDelta != 0 else { return }

        let dayShiftedStart = calendar.date(byAdding: .day, value: dayDelta, to: start) ?? start
        let dayShiftedEnd = calendar.date(byAdding: .day, value: dayDelta, to: end) ?? end
        let movedStart = calendar.date(byAdding: .minute, value: snappedMinuteDelta, to: dayShiftedStart) ?? dayShiftedStart
        let movedEnd = calendar.date(byAdding: .minute, value: snappedMinuteDelta, to: dayShiftedEnd) ?? dayShiftedEnd
        let movedDuration = movedEnd.timeIntervalSince(movedStart)

        item.plannedStart = movedStart
        item.plannedEnd = movedEnd
        if snappedMinuteDelta != 0 {
            item.usesDefaultLodgingTime = false
        }
        item.estimatedMinutes = max(Int(movedDuration / 60), safeStep)
    }

    static func conflictingItemIDs(in items: [TripItem]) -> Set<UUID> {
        let scheduled = items.compactMap { item -> (TripItem, Date, Date)? in
            guard let start = item.plannedStart, let end = item.plannedEnd, end > start else { return nil }
            return (item, start, end)
        }.sorted { $0.1 < $1.1 }
        var conflicts = Set<UUID>()
        var latestEnding: (item: TripItem, end: Date)?

        for current in scheduled {
            if let latestEnding, latestEnding.end > current.1 {
                conflicts.insert(current.0.id)
                conflicts.insert(latestEnding.item.id)
            }
            if latestEnding.map({ current.2 > $0.end }) ?? true {
                latestEnding = (current.0, current.2)
            }
        }
        return conflicts
    }
}
