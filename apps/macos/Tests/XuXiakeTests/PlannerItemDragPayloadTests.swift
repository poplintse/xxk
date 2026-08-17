import Foundation
import Testing
@testable import XuXiake

struct PlannerItemDragPayloadTests {
    @Test func preservesTheDraggedItemIdentifier() throws {
        let payload = PlannerItemDragPayload(itemID: UUID())

        let restoredPayload = try JSONDecoder().decode(
            PlannerItemDragPayload.self,
            from: JSONEncoder().encode(payload)
        )

        #expect(restoredPayload == payload)
    }
}
