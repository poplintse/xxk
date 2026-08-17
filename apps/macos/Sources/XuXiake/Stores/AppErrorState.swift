import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class AppErrorState {
    var title = ""
    var message: String?

    func present(title: String, message: String) {
        self.title = title
        self.message = message
    }

    func save(_ context: ModelContext, operation: String) {
        do {
            try context.save()
        } catch {
            present(
                title: "无法保存",
                message: "\(operation)没有保存成功。\n\n\(error.localizedDescription)"
            )
        }
    }
}
