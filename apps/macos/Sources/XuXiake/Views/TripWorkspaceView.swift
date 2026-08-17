import SwiftUI

struct TripWorkspaceView: View {
    let trip: Trip
    @SceneStorage("workspaceSection") private var selectedSectionRawValue = WorkspaceSection.planner.rawValue
    @State private var plannerAnchorDate: Date?
    @State private var showingTripEditor = false

    private var timeZone: TimeZone {
        TimeZone(identifier: trip.timeZoneIdentifier) ?? .current
    }

    private var selectedSection: Binding<WorkspaceSection> {
        Binding(
            get: { WorkspaceSection(rawValue: selectedSectionRawValue) ?? .planner },
            set: { selectedSectionRawValue = $0.rawValue }
        )
    }

    var body: some View {
        Group {
            switch selectedSection.wrappedValue {
            case .planner:
                PlannerView(
                    trip: trip,
                    anchorDate: Binding(
                        get: { plannerAnchorDate ?? trip.startDate },
                        set: { plannerAnchorDate = $0 }
                    )
                )
            case .month:
                MonthView(trip: trip) { date in
                    plannerAnchorDate = date
                    selectedSection.wrappedValue = .planner
                }
            case .itinerary:
                ItineraryView(trip: trip)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle(trip.title)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("视图", selection: selectedSection) {
                    ForEach(WorkspaceSection.allCases) { section in
                        Label(section.title, systemImage: section.systemImage)
                            .accessibilityLabel(section.title)
                            .tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 330)
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button { showingTripEditor = true } label: {
                    Label("旅行信息", systemImage: "calendar.badge.clock")
                }
                .labelStyle(.iconOnly)
                .help("编辑旅行日期和时区")
                .accessibilityLabel("编辑旅行信息")
                SettingsLink {
                    Label("设置", systemImage: "gearshape")
                }
                .labelStyle(.iconOnly)
                .help("打开设置")
                .accessibilityLabel("打开设置")
            }
        }
        .environment(\.timeZone, timeZone)
        .sheet(isPresented: $showingTripEditor) {
            TripEditorView(trip: trip)
        }
    }
}
