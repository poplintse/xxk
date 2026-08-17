import OSLog
import SwiftUI

private let plannerDragLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.iclawtse.xuxiake",
    category: "PlannerDrag"
)

struct WeekTimelineView: View {
    let days: [Date]
    let items: [TripItem]
    let calendar: Calendar
    let timelineStartHour: Int
    let showsConflictWarnings: Bool
    let onDrop: (String, Date, Int) -> Void
    let onEdit: (TripItem) -> Void
    let onUnplan: (TripItem) -> Void
    let onDelete: (TripItem) -> Void
    let onResize: (UUID, ScheduleResizeEdge, Int) -> Void
    let onMove: (UUID, Int, Int) -> Void

    private let hourHeight: CGFloat = 54
    private let dayWidth: CGFloat = 170

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            HStack(alignment: .top, spacing: 0) {
                TimeLabels(hourHeight: hourHeight, startHour: timelineStartHour)
                ForEach(days, id: \.self) { day in
                    DayTimelineColumn(
                        day: day,
                        items: items,
                        calendar: calendar,
                        hourHeight: hourHeight,
                        dayWidth: dayWidth,
                        startHour: timelineStartHour,
                        conflictingItemIDs: showsConflictWarnings ? ScheduleEngine.conflictingItemIDs(in: items) : [],
                        onDrop: onDrop,
                        onEdit: onEdit,
                        onUnplan: onUnplan,
                        onDelete: onDelete,
                        onResize: onResize,
                        onMove: onMove
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.background)
    }
}

private struct TimeLabels: View {
    let hourHeight: CGFloat
    let startHour: Int

    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: 42)
            ZStack(alignment: .topTrailing) {
                Color.clear.frame(width: 52, height: hourHeight * 24)
                ForEach(0..<24, id: \.self) { index in
                    Text(String(format: "%02d:00", (startHour + index) % 24))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .offset(y: CGFloat(index) * hourHeight - 7)
                }
            }
        }
    }
}

private struct DayTimelineColumn: View {
    let day: Date
    let items: [TripItem]
    let calendar: Calendar
    let hourHeight: CGFloat
    let dayWidth: CGFloat
    let startHour: Int
    let conflictingItemIDs: Set<UUID>
    let onDrop: (String, Date, Int) -> Void
    let onEdit: (TripItem) -> Void
    let onUnplan: (TripItem) -> Void
    let onDelete: (TripItem) -> Void
    let onResize: (UUID, ScheduleResizeEdge, Int) -> Void
    let onMove: (UUID, Int, Int) -> Void

    private var orderedItems: [TripItem] {
        items.filter { ScheduleEngine.timelineSegment(for: $0, on: day, startHour: startHour, calendar: calendar) != nil }
            .sorted { ($0.plannedStart ?? .distantFuture) < ($1.plannedStart ?? .distantFuture) }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text(AppFormatters.dayHeader(day, timeZone: calendar.timeZone)).font(.headline)
                Text(calendar.isDateInToday(day) ? "今天" : " ")
                    .font(.caption2)
                    .foregroundStyle(.tint)
            }
            .frame(width: dayWidth, height: 42)
            .background(.bar)

            ZStack(alignment: .topLeading) {
                HourGrid(hourHeight: hourHeight)
                ForEach(orderedItems) { item in
                    if let segment = ScheduleEngine.timelineSegment(for: item, on: day, startHour: startHour, calendar: calendar) {
                        TimelineItemBlock(
                            item: item,
                            segment: segment,
                            hourHeight: hourHeight,
                            dayWidth: dayWidth,
                            timeZone: calendar.timeZone,
                            hasConflict: conflictingItemIDs.contains(item.id),
                            onEdit: { onEdit(item) },
                            onUnplan: { onUnplan(item) },
                            onDelete: { onDelete(item) },
                            onResize: onResize,
                            onMove: onMove
                        )
                    }
                }
            }
            .frame(width: dayWidth, height: hourHeight * 24)
            .contentShape(Rectangle())
            .dropDestination(for: String.self) { itemIDs, location in
                guard let itemID = itemIDs.first else {
                    plannerDragLogger.error("Timeline drop rejected: no item identifier")
                    return false
                }
                let minuteFromVisibleStart = min(max(Int((location.y / hourHeight) * 60), 0), 24 * 60 - 1)
                let target = ScheduleEngine.dropTarget(
                    on: day,
                    minuteFromVisibleStart: minuteFromVisibleStart,
                    startHour: startHour,
                    calendar: calendar
                )
                plannerDragLogger.info("Timeline drop received")
                onDrop(itemID, target.day, target.minute)
                return true
            }
        }
        .overlay(alignment: .trailing) { Divider() }
    }
}

private struct HourGrid: View {
    let hourHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<24, id: \.self) { _ in
                Rectangle()
                    .fill(.clear)
                    .frame(height: hourHeight)
                    .overlay(alignment: .top) { Divider() }
            }
        }
    }
}

private struct TimelineItemBlock: View {
    let item: TripItem
    let segment: ScheduleSegment
    let hourHeight: CGFloat
    let dayWidth: CGFloat
    let timeZone: TimeZone
    let hasConflict: Bool
    let onEdit: () -> Void
    let onUnplan: () -> Void
    let onDelete: () -> Void
    let onResize: (UUID, ScheduleResizeEdge, Int) -> Void
    let onMove: (UUID, Int, Int) -> Void

    @State private var startDragHeight: CGFloat = 0
    @State private var endDragHeight: CGFloat = 0
    @State private var moveTranslation: CGSize = .zero

    private var visibleDuration: Int {
        max(segment.endMinute - segment.startMinute, 20)
    }

    private var baseHeight: CGFloat {
        max(CGFloat(visibleDuration) / 60 * hourHeight, 34)
    }

    private var previewHeight: CGFloat {
        max(baseHeight - startDragHeight + endDragHeight, 34)
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(item.title).font(.caption.weight(.medium)).lineLimit(2)
                    Spacer(minLength: 0)
                    if hasConflict {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .help("此事项与其他事项时间重叠")
                    }
                }
                if segment.continuesBefore || segment.continuesAfter {
                    Text(continuationLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else if let start = item.plannedStart, let end = item.plannedEnd {
                    Text("\(AppFormatters.time(start, timeZone: timeZone))–\(AppFormatters.time(end, timeZone: timeZone))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(6)

            VStack {
                if !segment.continuesBefore {
                    resizeHandle(edge: .start, translation: $startDragHeight)
                }
                Spacer()
                if !segment.continuesAfter {
                    resizeHandle(edge: .end, translation: $endDragHeight)
                }
            }
        }
        .frame(width: 160, height: previewHeight, alignment: .topLeading)
        .background(item.kind == .lodging ? Color.green.opacity(0.18) : Color.accentColor.opacity(0.16), in: RoundedRectangle(cornerRadius: 7))
        .overlay {
            RoundedRectangle(cornerRadius: 7)
                .stroke(hasConflict ? Color.red : Color.clear, lineWidth: 1.5)
        }
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(item.kind == .lodging ? Color.green : Color.accentColor)
                .frame(width: 3)
        }
        .offset(
            x: 5 + moveTranslation.width,
            y: CGFloat(segment.startMinute) / 60 * hourHeight + startDragHeight + moveTranslation.height
        )
        .gesture(moveGesture)
        .draggableCursor()
        .onTapGesture(count: 2, perform: onEdit)
        .contextMenu {
            Button("编辑", action: onEdit)
            Button("移回待安排", action: onUnplan)
            Divider()
            Button("删除", role: .destructive, action: onDelete)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
        .accessibilityValue(accessibilityScheduleValue)
        .accessibilityHint(hasConflict ? "与其他事项时间重叠" : "双击编辑，或上下调整持续时间")
        .accessibilityAction(named: "编辑", onEdit)
        .accessibilityAction(named: "移回待安排", onUnplan)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                onResize(item.id, .end, 15)
            case .decrement:
                onResize(item.id, .end, -15)
            @unknown default:
                break
            }
        }
    }

    private var continuationLabel: String {
        switch (segment.continuesBefore, segment.continuesAfter) {
        case (true, true): "连续住宿"
        case (true, false): "延续至此"
        case (false, true): "跨至下一天"
        case (false, false): ""
        }
    }

    private var accessibilityScheduleValue: String {
        guard let start = item.plannedStart, let end = item.plannedEnd else { return "未安排" }
        return "\(AppFormatters.dateTime(start, timeZone: timeZone)) 至 \(AppFormatters.dateTime(end, timeZone: timeZone))"
    }

    private var moveGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { moveTranslation = $0.translation }
            .onEnded { value in
                let dayDelta = Int((value.translation.width / dayWidth).rounded())
                let minuteDelta = Int(value.translation.height / hourHeight * 60)
                moveTranslation = .zero
                guard dayDelta != 0 || minuteDelta != 0 else { return }
                plannerDragLogger.info("Timeline block move completed")
                onMove(item.id, dayDelta, minuteDelta)
            }
    }

    private func resizeHandle(edge: ScheduleResizeEdge, translation: Binding<CGFloat>) -> some View {
        Capsule()
            .fill(.secondary.opacity(0.55))
            .frame(width: 34, height: 4)
            .padding(.vertical, 4)
            .contentShape(Rectangle().inset(by: -5))
            .highPriorityGesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { translation.wrappedValue = $0.translation.height }
                    .onEnded { value in
                        let deltaMinutes = Int(value.translation.height / hourHeight * 60)
                        translation.wrappedValue = 0
                        onResize(item.id, edge, deltaMinutes)
                    }
            )
            .help(edge == .start ? "拖动调整开始时间" : "拖动调整结束时间")
            .accessibilityHidden(true)
    }
}
