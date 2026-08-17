import Foundation

enum WorkspaceSection: String, CaseIterable, Identifiable {
    case planner
    case month
    case itinerary

    var id: Self { self }

    var title: String {
        switch self {
        case .planner: "规划"
        case .month: "月览"
        case .itinerary: "行程表"
        }
    }

    var systemImage: String {
        switch self {
        case .planner: "calendar.day.timeline.left"
        case .month: "calendar"
        case .itinerary: "tablecells"
        }
    }
}
