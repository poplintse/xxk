import SwiftData
import SwiftUI

struct TripEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppErrorState.self) private var errorState
    let trip: Trip

    @State private var title: String
    @State private var destination: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var timeZoneIdentifier: String

    init(trip: Trip) {
        self.trip = trip
        _title = State(initialValue: trip.title)
        _destination = State(initialValue: trip.destination)
        _startDate = State(initialValue: trip.startDate)
        _endDate = State(initialValue: trip.endDate)
        _timeZoneIdentifier = State(initialValue: trip.timeZoneIdentifier)
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        endDate >= startDate &&
        TimeZone(identifier: timeZoneIdentifier) != nil
    }

    private var selectedTimeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("旅行") {
                    TextField("名称", text: $title)
                    TextField("目的地", text: $destination)
                    DatePicker("开始日期", selection: $startDate, displayedComponents: .date)
                    DatePicker("结束日期", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
                Section("时间") {
                    TextField("时区", text: $timeZoneIdentifier)
                    if TimeZone(identifier: timeZoneIdentifier) == nil {
                        Text("请输入有效时区，例如 Asia/Shanghai。")
                            .foregroundStyle(.red)
                    }
                    Text("规划中的日期和时间会按照旅行时区计算。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("旅行信息")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .accessibilityLabel("取消")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                        .disabled(!isValid)
                        .accessibilityLabel("保存旅行信息")
                }
            }
        }
        .frame(width: 500, height: 430)
        .environment(\.timeZone, selectedTimeZone)
    }

    private func save() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = selectedTimeZone
        trip.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        trip.destination = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        trip.startDate = calendar.startOfDay(for: startDate)
        trip.endDate = calendar.startOfDay(for: endDate)
        trip.timeZoneIdentifier = timeZoneIdentifier
        errorState.save(modelContext, operation: "编辑旅行")
        if errorState.message == nil { dismiss() }
    }
}
