import Foundation
import SwiftData

@Model
final class Trip {
    @Attribute(.unique) var id: UUID
    var title: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var timeZoneIdentifier: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \TripItem.trip)
    var items: [TripItem]

    init(
        id: UUID = UUID(),
        title: String,
        destination: String,
        startDate: Date,
        endDate: Date,
        timeZoneIdentifier: String = TimeZone.current.identifier,
        createdAt: Date = .now,
        items: [TripItem] = []
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.timeZoneIdentifier = timeZoneIdentifier
        self.createdAt = createdAt
        self.items = items
    }
}
