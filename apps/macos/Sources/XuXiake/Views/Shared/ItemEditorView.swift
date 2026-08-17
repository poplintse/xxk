import SwiftData
import SwiftUI

struct ItemEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppPreferences.self) private var preferences
    @Environment(AppErrorState.self) private var errorState

    let trip: Trip
    let item: TripItem?

    @State private var title: String
    @State private var kind: TripItemKind
    @State private var priority: TripItemPriority
    @State private var estimatedMinutes: Int
    @State private var lodgingNights: Int
    @State private var usesDefaultLodgingTime: Bool
    @State private var location: String
    @State private var route: String
    @State private var cost: Double
    @State private var details: String
    @State private var importantNotes: String
    @State private var isScheduled: Bool
    @State private var plannedStart: Date
    @State private var plannedEnd: Date

    init(trip: Trip, item: TripItem? = nil) {
        self.trip = trip
        self.item = item
        let defaultStart = item?.plannedStart ?? trip.startDate
        _title = State(initialValue: item?.title ?? "")
        _kind = State(initialValue: item?.kind ?? .attraction)
        _priority = State(initialValue: item?.priority ?? .wantToDo)
        _estimatedMinutes = State(initialValue: item?.estimatedMinutes ?? 120)
        _lodgingNights = State(initialValue: item?.lodgingNights ?? 1)
        _usesDefaultLodgingTime = State(initialValue: item?.usesDefaultLodgingTime ?? true)
        _location = State(initialValue: item?.location ?? "")
        _route = State(initialValue: item?.route ?? "")
        _cost = State(initialValue: Double(item?.costInMinorUnits ?? 0) / 100)
        _details = State(initialValue: item?.details ?? "")
        _importantNotes = State(initialValue: item?.importantNotes ?? "")
        _isScheduled = State(initialValue: item?.isScheduled ?? false)
        _plannedStart = State(initialValue: defaultStart)
        _plannedEnd = State(initialValue: item?.plannedEnd ?? defaultStart.addingTimeInterval(2 * 60 * 60))
    }

    private var hasValidSchedule: Bool { !isScheduled || plannedEnd > plannedStart }

    private var tripTimeZone: TimeZone {
        TimeZone(identifier: trip.timeZoneIdentifier) ?? .current
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("事项") {
                    TextField("名称", text: $title)
                    Picker("类型", selection: $kind) {
                        ForEach(TripItemKind.allCases) { kind in Text(kind.title).tag(kind) }
                    }
                    Picker("优先级", selection: $priority) {
                        ForEach(TripItemPriority.allCases) { priority in Text(priority.title).tag(priority) }
                    }
                    if kind == .lodging {
                        Stepper("住宿 \(lodgingNights) 晚", value: $lodgingNights, in: 1...30)
                        Toggle("使用设置中的默认入住和退房时间", isOn: $usesDefaultLodgingTime)
                    } else {
                        Stepper("预计 \(estimatedMinutes) 分钟", value: $estimatedMinutes, in: 15...24 * 60, step: 15)
                    }
                }

                Section("计划时间") {
                    Toggle("已经安排", isOn: $isScheduled)
                    if isScheduled {
                        DatePicker("开始", selection: $plannedStart)
                            .disabled(kind == .lodging && usesDefaultLodgingTime)
                        DatePicker("结束", selection: $plannedEnd)
                            .disabled(kind == .lodging && usesDefaultLodgingTime)
                        if kind == .lodging && usesDefaultLodgingTime {
                            Text("保存后按入住日期、住宿晚数和系统默认时间自动计算。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !hasValidSchedule {
                            Text("结束时间必须晚于开始时间。")
                                .foregroundStyle(.red)
                        }
                    }
                }

                Section("行程信息") {
                    TextField("地点", text: $location)
                    TextField("路线", text: $route)
                    TextField("预计费用", value: $cost, format: .number.precision(.fractionLength(2)))
                }
                Section("内容") {
                    TextField("具体内容", text: $details, axis: .vertical)
                    TextField("重点事项", text: $importantNotes, axis: .vertical)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(item == nil ? "新建事项" : "编辑事项")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .accessibilityLabel("取消")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(item == nil ? "添加" : "保存", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !hasValidSchedule)
                        .accessibilityLabel(item == nil ? "添加事项" : "保存事项")
                }
            }
        }
        .frame(width: 520, height: 640)
        .environment(\.timeZone, tripTimeZone)
    }

    private func save() {
        let target = item ?? TripItem(
            title: title,
            kind: kind,
            currencyCode: preferences.currencyCode
        )
        target.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        target.kind = kind
        target.priority = priority
        target.estimatedMinutes = estimatedMinutes
        target.location = location
        target.route = route
        target.costInMinorUnits = AppFormatters.minorUnits(from: cost)
        target.details = details
        target.importantNotes = importantNotes
        target.lodgingNights = lodgingNights
        target.usesDefaultLodgingTime = usesDefaultLodgingTime
        if isScheduled, kind == .lodging, usesDefaultLodgingTime {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: trip.timeZoneIdentifier) ?? .current
            ScheduleEngine.schedule(target, on: plannedStart, minute: 0, calendar: calendar, preferences: preferences)
        } else {
            target.plannedStart = isScheduled ? plannedStart : nil
            target.plannedEnd = isScheduled ? plannedEnd : nil
            if isScheduled {
                target.estimatedMinutes = max(Int(plannedEnd.timeIntervalSince(plannedStart) / 60), preferences.timelineStepMinutes)
            }
        }

        if item == nil {
            modelContext.insert(target)
            trip.items.append(target)
        }
        errorState.save(modelContext, operation: item == nil ? "添加事项" : "编辑事项")
        if errorState.message == nil { dismiss() }
    }
}
