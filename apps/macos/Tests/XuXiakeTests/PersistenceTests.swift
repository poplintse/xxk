import Foundation
import SwiftData
import Testing
@testable import XuXiake

@MainActor
struct PersistenceTests {
    @Test func tripAndItemRoundTripThroughSwiftData() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, TripItem.self, configurations: configuration)
        let context = container.mainContext
        let trip = Trip(title: "杭州五日", destination: "杭州", startDate: .now, endDate: .now.addingTimeInterval(4 * 86_400))
        context.insert(trip)
        let item = TripItem(title: "灵隐寺", kind: .attraction, priority: .mustDo)
        trip.items.append(item)
        try context.save()

        let fetchedTrips = try context.fetch(FetchDescriptor<Trip>())

        #expect(fetchedTrips.count == 1)
        #expect(fetchedTrips[0].items.count == 1)
        #expect(fetchedTrips[0].items[0].title == "灵隐寺")
        #expect(fetchedTrips[0].items[0].trip?.id == fetchedTrips[0].id)
    }

    @Test func completeItinerarySurvivesStoreReopen() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("XuXiakeTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appendingPathComponent("XuXiake.store")
        let tripID = UUID()
        let itemID = UUID()
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        let end = start.addingTimeInterval(40 * 60 * 60)

        do {
            let configuration = ModelConfiguration(url: storeURL)
            let container = try ModelContainer(for: Trip.self, TripItem.self, configurations: configuration)
            let trip = Trip(
                id: tripID,
                title: "京都三日",
                destination: "京都",
                startDate: start,
                endDate: end,
                timeZoneIdentifier: "Asia/Tokyo"
            )
            container.mainContext.insert(trip)
            let item = TripItem(
                id: itemID,
                title: "町家住宿",
                kind: .lodging,
                priority: .mustDo,
                plannedStart: start,
                plannedEnd: end,
                estimatedMinutes: 40 * 60,
                location: "祇园",
                route: "京都站 → 祇园四条",
                costInMinorUnits: 125_000,
                currencyCode: "JPY",
                details: "传统町家",
                importantNotes: "入住前联系房东",
                lodgingNights: 2,
                usesDefaultLodgingTime: false
            )
            trip.items.append(item)
            try container.mainContext.save()
        }

        let reopenedConfiguration = ModelConfiguration(url: storeURL)
        let reopenedContainer = try ModelContainer(
            for: Trip.self,
            TripItem.self,
            configurations: reopenedConfiguration
        )
        let trips = try reopenedContainer.mainContext.fetch(FetchDescriptor<Trip>())
        let items = try reopenedContainer.mainContext.fetch(FetchDescriptor<TripItem>())

        #expect(trips.count == 1)
        #expect(items.count == 1)
        #expect(trips[0].id == tripID)
        #expect(trips[0].timeZoneIdentifier == "Asia/Tokyo")
        #expect(items[0].id == itemID)
        #expect(items[0].kind == .lodging)
        #expect(items[0].priority == .mustDo)
        #expect(items[0].plannedStart == start)
        #expect(items[0].plannedEnd == end)
        #expect(items[0].route == "京都站 → 祇园四条")
        #expect(items[0].costInMinorUnits == 125_000)
        #expect(items[0].currencyCode == "JPY")
        #expect(items[0].details == "传统町家")
        #expect(items[0].importantNotes == "入住前联系房东")
        #expect(items[0].lodgingNights == 2)
        #expect(items[0].usesDefaultLodgingTime == false)
        #expect(items[0].trip?.id == tripID)
    }

    @Test func deletingTripCascadesToItsItems() throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Trip.self, TripItem.self, configurations: configuration)
        let context = container.mainContext
        let trip = Trip(title: "待删除旅行", destination: "", startDate: .now, endDate: .now)
        context.insert(trip)
        trip.items.append(TripItem(title: "待删除事项", kind: .other))
        try context.save()

        context.delete(trip)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<Trip>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<TripItem>()) == 0)
    }
}
