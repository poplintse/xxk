import CoreTransferable
import Foundation
import UniformTypeIdentifiers

struct PlannerItemDragPayload: Codable, Equatable, Transferable {
    let itemID: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .plannerItem)
    }
}

extension UTType {
    static let plannerItem = UTType(exportedAs: "com.iclawtse.xuxiake.planner-item")
}
