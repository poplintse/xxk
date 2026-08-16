import SwiftUI

struct SettingsView: View {
    @Environment(AppPreferences.self) private var preferences

    var body: some View {
        @Bindable var preferences = preferences
        TabView {
            Form {
                Section("住宿时间") {
                    TimeOfDayPicker("默认入住", minutes: $preferences.lodgingCheckInMinutes)
                    TimeOfDayPicker("默认退房", minutes: $preferences.lodgingCheckOutMinutes)
                }
                Section("时间轴") {
                    Picker("开始显示", selection: $preferences.timelineStartHour) {
                        Text("00:00").tag(0)
                        Text("06:00").tag(6)
                        Text("08:00").tag(8)
                    }
                    Picker("吸附粒度", selection: $preferences.timelineStepMinutes) {
                        Text("5 分钟").tag(5)
                        Text("15 分钟").tag(15)
                        Text("30 分钟").tag(30)
                    }
                    Toggle("显示时间重叠提示", isOn: $preferences.warnsAboutOverlap)
                }
            }
            .formStyle(.grouped)
            .tabItem { Label("规划", systemImage: "calendar") }

            Form {
                Picker("默认币种", selection: $preferences.currencyCode) {
                    Text("人民币 CNY").tag("CNY")
                    Text("美元 USD").tag("USD")
                    Text("欧元 EUR").tag("EUR")
                    Text("日元 JPY").tag("JPY")
                }
            }
            .formStyle(.grouped)
            .tabItem { Label("通用", systemImage: "gearshape") }
        }
        .frame(width: 480, height: 330)
        .scenePadding()
    }
}

private struct TimeOfDayPicker: View {
    let title: String
    @Binding var minutes: Int

    init(_ title: String, minutes: Binding<Int>) {
        self.title = title
        _minutes = minutes
    }

    private var hour: Binding<Int> {
        Binding(
            get: { min(max(minutes / 60, 0), 23) },
            set: { minutes = $0 * 60 + minute.wrappedValue }
        )
    }

    private var minute: Binding<Int> {
        Binding(
            get: { min(max(minutes % 60, 0), 59) / 15 * 15 },
            set: { minutes = hour.wrappedValue * 60 + $0 }
        )
    }

    var body: some View {
        LabeledContent(title) {
            HStack(spacing: 6) {
                Picker("小时", selection: hour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(String(format: "%02d", hour)).tag(hour)
                    }
                }
                .frame(width: 72)

                Text(":")

                Picker("分钟", selection: minute) {
                    ForEach([0, 15, 30, 45], id: \.self) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .frame(width: 72)
            }
        }
    }
}
