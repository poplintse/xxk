import SwiftUI

struct MonthView: View {
    let trip: Trip
    let onSelectDate: (Date) -> Void
    @State private var monthOffset = 0

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.timeZone = TimeZone(identifier: trip.timeZoneIdentifier) ?? .current
        return calendar
    }

    private var displayedMonth: Date {
        calendar.date(byAdding: .month, value: monthOffset, to: trip.startDate) ?? trip.startDate
    }

    private var gridDates: [Date] {
        guard let month = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfYear, for: month.start),
              let monthEndWeek = calendar.dateInterval(of: .weekOfYear, for: month.end.addingTimeInterval(-1)) else { return [] }
        let finalDate = calendar.date(byAdding: .day, value: 7, to: monthEndWeek.start) ?? month.end
        var dates: [Date] = []
        var date = firstWeek.start
        while date < finalDate {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? finalDate
        }
        return dates
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { monthOffset -= 1 } label: { Image(systemName: "chevron.left") }
                    .accessibilityLabel("上个月")
                Button("本月") { monthOffset = 0 }
                    .accessibilityLabel("回到旅行开始月份")
                Button { monthOffset += 1 } label: { Image(systemName: "chevron.right") }
                    .accessibilityLabel("下个月")
                Text(AppFormatters.monthTitle(displayedMonth, timeZone: calendar.timeZone))
                    .font(.title3.weight(.semibold))
                    .padding(.leading, 6)
                Spacer()
                Text("\(trip.items.filter(\.isScheduled).count) 个已安排事项")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .padding(12)

            Divider()

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                    ForEach(Array(calendar.veryShortWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                        Text(symbol).font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity).padding(7)
                    }
                    ForEach(gridDates, id: \.self) { date in
                        MonthDayCell(
                            date: date,
                            isCurrentMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month),
                            items: items(on: date),
                            calendar: calendar,
                            onSelect: { onSelectDate(date) }
                        )
                    }
                }
                .padding(12)
            }
        }
    }

    private func items(on date: Date) -> [TripItem] {
        trip.items.filter { ScheduleEngine.segment(for: $0, on: date, calendar: calendar) != nil }
            .sorted { ($0.plannedStart ?? .distantFuture) < ($1.plannedStart ?? .distantFuture) }
    }
}

private struct MonthDayCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let items: [TripItem]
    let calendar: Calendar
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(AppFormatters.dayNumber(date, timeZone: calendar.timeZone))
                .font(.caption.weight(calendar.isDateInToday(date) ? .bold : .regular))
                .foregroundStyle(isCurrentMonth ? .primary : .tertiary)
            ForEach(items.prefix(3)) { item in
                HStack(spacing: 4) {
                    Image(systemName: item.kind.systemImage)
                    Text(item.title).lineLimit(1)
                }
                .font(.caption2)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(item.kind == .lodging ? Color.green.opacity(0.16) : Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))
            }
            if items.count > 3 {
                Text("另有 \(items.count - 3) 项").font(.caption2).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(7)
        .frame(minHeight: 105, alignment: .topLeading)
        .overlay { Rectangle().stroke(.separator.opacity(0.5), lineWidth: 0.5) }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: onSelect)
        .contextMenu {
            Button("在规划视图中打开", action: onSelect)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAction(named: "在规划视图中打开", onSelect)
    }

    private var accessibilityLabel: String {
        let day = AppFormatters.dayHeader(date, timeZone: calendar.timeZone)
        guard !items.isEmpty else { return "\(day)，没有安排" }
        return "\(day)，\(items.count) 个事项：\(items.map(\.title).joined(separator: "、"))"
    }
}
