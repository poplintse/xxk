import Foundation
import SwiftData

enum TripItemKind: String, CaseIterable, Codable, Identifiable {
    case attraction
    case lodging
    case transportation
    case dining
    case shopping
    case other

    var id: Self { self }

    var title: String {
        switch self {
        case .attraction: "游玩参观"
        case .lodging: "住宿"
        case .transportation: "交通"
        case .dining: "餐饮"
        case .shopping: "购物"
        case .other: "其他"
        }
    }

    var systemImage: String {
        switch self {
        case .attraction: "figure.hiking"
        case .lodging: "bed.double"
        case .transportation: "tram"
        case .dining: "fork.knife"
        case .shopping: "bag"
        case .other: "square.grid.2x2"
        }
    }
}

enum TripItemPriority: String, CaseIterable, Codable, Identifiable {
    case mustDo
    case wantToDo

    var id: Self { self }
    var title: String { self == .mustDo ? "必须" : "想去" }
}

@Model
final class TripItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var kindRawValue: String
    var priorityRawValue: String
    var plannedStart: Date?
    var plannedEnd: Date?
    var estimatedMinutes: Int
    var location: String
    var route: String
    var costInMinorUnits: Int
    var currencyCode: String
    var details: String
    var importantNotes: String
    var lodgingNights: Int
    var usesDefaultLodgingTime: Bool
    var createdAt: Date
    var trip: Trip?

    var kind: TripItemKind {
        get { TripItemKind(rawValue: kindRawValue) ?? .other }
        set { kindRawValue = newValue.rawValue }
    }

    var priority: TripItemPriority {
        get { TripItemPriority(rawValue: priorityRawValue) ?? .wantToDo }
        set { priorityRawValue = newValue.rawValue }
    }

    var isScheduled: Bool { plannedStart != nil && plannedEnd != nil }

    init(
        id: UUID = UUID(),
        title: String,
        kind: TripItemKind,
        priority: TripItemPriority = .wantToDo,
        plannedStart: Date? = nil,
        plannedEnd: Date? = nil,
        estimatedMinutes: Int = 120,
        location: String = "",
        route: String = "",
        costInMinorUnits: Int = 0,
        currencyCode: String = "CNY",
        details: String = "",
        importantNotes: String = "",
        lodgingNights: Int = 1,
        usesDefaultLodgingTime: Bool = true,
        createdAt: Date = .now,
        trip: Trip? = nil
    ) {
        self.id = id
        self.title = title
        self.kindRawValue = kind.rawValue
        self.priorityRawValue = priority.rawValue
        self.plannedStart = plannedStart
        self.plannedEnd = plannedEnd
        self.estimatedMinutes = estimatedMinutes
        self.location = location
        self.route = route
        self.costInMinorUnits = costInMinorUnits
        self.currencyCode = currencyCode
        self.details = details
        self.importantNotes = importantNotes
        self.lodgingNights = lodgingNights
        self.usesDefaultLodgingTime = usesDefaultLodgingTime
        self.createdAt = createdAt
        self.trip = trip
    }
}
