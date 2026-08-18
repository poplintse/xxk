import SwiftData
import SwiftUI

struct PlannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppPreferences.self) private var preferences
    @Environment(AppErrorState.self) private var errorState
    let trip: Trip
    @Binding var anchorDate: Date

    @State private var showingNewItem = false
    @State private var editingItem: TripItem?
    @State private var itemPendingDeletion: TripItem?

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.timeZone = TimeZone(identifier: trip.timeZoneIdentifier) ?? .current
        return calendar
    }

    private var weekDays: [Date] {
        let start = calendar.dateInterval(of: .weekOfYear, for: anchorDate)?.start ?? calendar.startOfDay(for: anchorDate)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        HSplitView {
            UnscheduledItemsPanel(
                items: trip.items.filter { !$0.isScheduled }.sorted { $0.createdAt < $1.createdAt },
                scheduledItems: trip.items.filter(\.isScheduled).sorted { ($0.plannedStart ?? .distantFuture) < ($1.plannedStart ?? .distantFuture) },
                timeZone: calendar.timeZone,
                onAdd: { showingNewItem = true },
                onEdit: { editingItem = $0 },
                onDropItemID: unplan,
                onDelete: { itemPendingDeletion = $0 }
            )
            .frame(minWidth: 210, idealWidth: 240, maxWidth: 310, maxHeight: .infinity)

            VStack(spacing: 0) {
                PlannerToolbar(
                    visibleStart: weekDays.first ?? trip.startDate,
                    timeZone: calendar.timeZone,
                    onPrevious: { anchorDate = calendar.date(byAdding: .day, value: -7, to: anchorDate) ?? anchorDate },
                    onToday: { anchorDate = .now },
                    onNext: { anchorDate = calendar.date(byAdding: .day, value: 7, to: anchorDate) ?? anchorDate }
                )
                Divider()
                WeekTimelineView(
                    days: weekDays,
                    items: trip.items,
                    calendar: calendar,
                    timelineStartHour: preferences.timelineStartHour,
                    showsConflictWarnings: preferences.warnsAboutOverlap,
                    onDrop: schedule,
                    onCreate: createScheduledItem,
                    onEdit: { editingItem = $0 },
                    onUnplan: unplan,
                    onDelete: { itemPendingDeletion = $0 },
                    onResize: resize,
                    onMove: move
                )
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showingNewItem) {
            ItemEditorView(trip: trip)
        }
        .sheet(item: $editingItem) { item in
            ItemEditorView(trip: trip, item: item)
        }
        .focusedSceneValue(\.newItemAction, NewItemAction { showingNewItem = true })
        .confirmationDialog(
            "删除“\(itemPendingDeletion?.title ?? "此事项")”？",
            isPresented: Binding(
                get: { itemPendingDeletion != nil },
                set: { if !$0 { itemPendingDeletion = nil } }
            )
        ) {
            Button("删除事项", role: .destructive) {
                if let itemPendingDeletion { delete(itemPendingDeletion) }
                itemPendingDeletion = nil
            }
            Button("取消", role: .cancel) { itemPendingDeletion = nil }
        } message: {
            Text("计划时间、路线、费用和备注会一起删除，此操作无法撤销。")
        }
    }

    private func schedule(itemID: UUID, day: Date, minute: Int) {
        guard let item = trip.items.first(where: { $0.id == itemID }) else { return }
        ScheduleEngine.schedule(item, on: day, minute: minute, calendar: calendar, preferences: preferences)
        errorState.save(modelContext, operation: "安排事项")
    }

    private func createScheduledItem(on day: Date, minute: Int, title: String) {
        let item = TripItem(
            title: title,
            kind: .other,
            estimatedMinutes: 120,
            currencyCode: preferences.currencyCode
        )
        ScheduleEngine.schedule(item, on: day, minute: minute, calendar: calendar, preferences: preferences)
        modelContext.insert(item)
        trip.items.append(item)
        errorState.save(modelContext, operation: "添加事项")
    }

    private func delete(_ item: TripItem) {
        modelContext.delete(item)
        errorState.save(modelContext, operation: "删除事项")
    }

    private func unplan(_ item: TripItem) {
        item.plannedStart = nil
        item.plannedEnd = nil
        errorState.save(modelContext, operation: "取消安排")
    }

    private func unplan(itemID: UUID) -> Bool {
        guard let item = trip.items.first(where: { $0.id == itemID }) else { return false }
        unplan(item)
        return true
    }

    private func resize(itemID: UUID, edge: ScheduleResizeEdge, deltaMinutes: Int) {
        guard let item = trip.items.first(where: { $0.id == itemID }) else { return }
        ScheduleEngine.resize(item, edge: edge, deltaMinutes: deltaMinutes, step: preferences.timelineStepMinutes)
        errorState.save(modelContext, operation: "调整事项时间")
    }

    private func move(itemID: UUID, dayDelta: Int, minuteDelta: Int) {
        guard let item = trip.items.first(where: { $0.id == itemID }) else { return }
        ScheduleEngine.move(
            item,
            dayDelta: dayDelta,
            minuteDelta: minuteDelta,
            step: preferences.timelineStepMinutes,
            calendar: calendar
        )
        errorState.save(modelContext, operation: "移动事项时间")
    }
}

private struct PlannerToolbar: View {
    let visibleStart: Date
    let timeZone: TimeZone
    let onPrevious: () -> Void
    let onToday: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Button(action: onPrevious) { Image(systemName: "chevron.left") }
                .accessibilityLabel("上一周")
            Button("今天", action: onToday)
                .accessibilityLabel("回到今天")
            Button(action: onNext) { Image(systemName: "chevron.right") }
                .accessibilityLabel("下一周")
            Text(AppFormatters.dayHeader(visibleStart, timeZone: timeZone))
                .font(.headline)
                .padding(.leading, 4)
            Spacer()
            Text("将左侧事项拖到时间轴")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, 12)
        .frame(height: 42)
    }
}
