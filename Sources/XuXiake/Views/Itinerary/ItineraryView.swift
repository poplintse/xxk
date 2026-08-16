import SwiftUI

struct ItineraryView: View {
    let trip: Trip
    @State private var selectedItemID: UUID?

    private var timeZone: TimeZone {
        TimeZone(identifier: trip.timeZoneIdentifier) ?? .current
    }

    private var scheduledItems: [TripItem] {
        trip.items.filter(\.isScheduled).sorted { ($0.plannedStart ?? .distantFuture) < ($1.plannedStart ?? .distantFuture) }
    }

    private var selectedItem: TripItem? {
        guard let selectedItemID else { return nil }
        return trip.items.first { $0.id == selectedItemID }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("详细旅行规划表").font(.title3.weight(.semibold))
                    Text("时间、路线、费用、内容和重点事项来自同一份计划数据。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("预计合计 \(AppFormatters.moneySummary(scheduledItems.map { ($0.costInMinorUnits, $0.currencyCode) }))")
                    .font(.headline)
            }
            .padding(14)
            Divider()

            if scheduledItems.isEmpty {
                ContentUnavailableView("还没有已安排事项", systemImage: "tablecells", description: Text("先在规划视图中把事项拖到时间轴。"))
            } else {
                Table(scheduledItems, selection: $selectedItemID) {
                    TableColumn("时间") { item in
                        VStack(alignment: .leading) {
                            Text(item.plannedStart.map { AppFormatters.dateTime($0, timeZone: timeZone) } ?? "—")
                            Text(item.plannedEnd.map { AppFormatters.time($0, timeZone: timeZone) } ?? "—")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .width(min: 130, ideal: 160)
                    TableColumn("事项") { item in
                        Label(item.title, systemImage: item.kind.systemImage)
                    }
                    .width(min: 130, ideal: 190)
                    TableColumn("路线") { item in
                        Text(item.route.isEmpty ? "—" : item.route).lineLimit(2)
                    }
                    .width(min: 120, ideal: 180)
                    TableColumn("内容") { item in
                        Text(item.details.isEmpty ? "—" : item.details).lineLimit(2)
                    }
                    .width(min: 140, ideal: 210)
                    TableColumn("费用") { item in
                        Text(AppFormatters.money(minorUnits: item.costInMinorUnits, currencyCode: item.currencyCode))
                    }
                    .width(90)
                    TableColumn("重点事项") { item in
                        Text(item.importantNotes.isEmpty ? "—" : item.importantNotes).lineLimit(2)
                    }
                    .width(min: 130, ideal: 220)
                }
                .inspector(isPresented: Binding(
                    get: { selectedItem != nil },
                    set: { if !$0 { selectedItemID = nil } }
                )) {
                    if let selectedItem {
                        ItineraryInspector(trip: trip, item: selectedItem)
                            .inspectorColumnWidth(min: 260, ideal: 320, max: 420)
                    }
                }
            }
        }
    }
}

private struct ItineraryInspector: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppPreferences.self) private var preferences
    @Environment(AppErrorState.self) private var errorState

    let trip: Trip
    @Bindable var item: TripItem

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: trip.timeZoneIdentifier) ?? .current
        return calendar
    }

    private var kind: Binding<TripItemKind> {
        Binding(
            get: { item.kind },
            set: { newKind in
                item.kind = newKind
                if newKind == .lodging, item.isScheduled, item.usesDefaultLodgingTime {
                    applyDefaultLodgingSchedule()
                }
            }
        )
    }

    private var lodgingNights: Binding<Int> {
        Binding(
            get: { item.lodgingNights },
            set: { nights in
                item.lodgingNights = nights
                if item.isScheduled, item.usesDefaultLodgingTime {
                    applyDefaultLodgingSchedule()
                }
            }
        )
    }

    private var usesDefaultLodgingTime: Binding<Bool> {
        Binding(
            get: { item.usesDefaultLodgingTime },
            set: { usesDefault in
                item.usesDefaultLodgingTime = usesDefault
                if usesDefault, item.isScheduled {
                    applyDefaultLodgingSchedule()
                } else {
                    updateEstimatedDuration()
                }
            }
        )
    }

    private var isScheduled: Binding<Bool> {
        Binding(
            get: { item.isScheduled },
            set: { scheduled in
                if scheduled, !item.isScheduled {
                    ScheduleEngine.schedule(
                        item,
                        on: trip.startDate,
                        minute: preferences.timelineStartHour * 60,
                        calendar: calendar,
                        preferences: preferences
                    )
                } else if !scheduled {
                    item.plannedStart = nil
                    item.plannedEnd = nil
                }
            }
        )
    }

    private var startDate: Binding<Date> {
        Binding(
            get: { item.plannedStart ?? .now },
            set: { newValue in
                item.plannedStart = newValue
                if let end = item.plannedEnd, end <= newValue {
                    item.plannedEnd = newValue.addingTimeInterval(15 * 60)
                }
                item.usesDefaultLodgingTime = false
                updateEstimatedDuration()
            }
        )
    }

    private var endDate: Binding<Date> {
        Binding(
            get: { item.plannedEnd ?? Date.now.addingTimeInterval(2 * 60 * 60) },
            set: { newValue in
                let minimum = (item.plannedStart ?? .now).addingTimeInterval(15 * 60)
                item.plannedEnd = max(newValue, minimum)
                item.usesDefaultLodgingTime = false
                updateEstimatedDuration()
            }
        )
    }

    private var cost: Binding<Double> {
        Binding(
            get: { Double(item.costInMinorUnits) / 100 },
            set: { item.costInMinorUnits = AppFormatters.minorUnits(from: $0) }
        )
    }

    var body: some View {
        Form {
            Section("事项") {
                TextField("名称", text: $item.title)
                Picker("类型", selection: kind) {
                    ForEach(TripItemKind.allCases) { kind in Text(kind.title).tag(kind) }
                }
                Picker("优先级", selection: Binding(get: { item.priority }, set: { item.priority = $0 })) {
                    ForEach(TripItemPriority.allCases) { priority in Text(priority.title).tag(priority) }
                }
                if item.kind == .lodging {
                    Stepper("住宿 \(item.lodgingNights) 晚", value: lodgingNights, in: 1...30)
                    Toggle("使用默认入住和退房时间", isOn: usesDefaultLodgingTime)
                }
            }
            Section("计划时间") {
                Toggle("已经安排", isOn: isScheduled)
                if item.isScheduled {
                    DatePicker("开始", selection: startDate)
                        .disabled(item.kind == .lodging && item.usesDefaultLodgingTime)
                    DatePicker("结束", selection: endDate)
                        .disabled(item.kind == .lodging && item.usesDefaultLodgingTime)
                }
            }
            Section("路线与内容") {
                TextField("地点", text: $item.location)
                TextField("路线", text: $item.route, axis: .vertical)
                TextField("预计费用", value: cost, format: .number.precision(.fractionLength(2)))
                TextField("具体内容", text: $item.details, axis: .vertical)
                TextField("重点事项", text: $item.importantNotes, axis: .vertical)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("事项详情")
        .environment(\.timeZone, calendar.timeZone)
        .onDisappear {
            errorState.save(modelContext, operation: "编辑行程事项")
        }
    }

    private func applyDefaultLodgingSchedule() {
        guard item.kind == .lodging else { return }
        ScheduleEngine.schedule(
            item,
            on: item.plannedStart ?? trip.startDate,
            minute: 0,
            calendar: calendar,
            preferences: preferences
        )
    }

    private func updateEstimatedDuration() {
        guard let start = item.plannedStart, let end = item.plannedEnd, end > start else { return }
        item.estimatedMinutes = max(Int(end.timeIntervalSince(start) / 60), preferences.timelineStepMinutes)
    }
}
