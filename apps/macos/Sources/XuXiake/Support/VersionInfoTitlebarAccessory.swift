import AppKit
import SwiftUI

@MainActor
struct VersionInfoTitlebarAccessory: NSViewRepresentable {
    let text: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        NSView(frame: .zero)
    }

    func updateNSView(_ view: NSView, context: Context) {
        let text = text
        DispatchQueue.main.async {
            context.coordinator.install(text: text, in: view.window)
        }
    }

    static func dismantleNSView(_ view: NSView, coordinator: Coordinator) {
        coordinator.remove()
    }

    @MainActor
    final class Coordinator {
        private weak var window: NSWindow?
        private var accessoryController: NSTitlebarAccessoryViewController?

        func install(text: String, in window: NSWindow?) {
            guard let window else { return }

            if self.window === window, let label = accessoryController?.view as? NSTextField {
                label.stringValue = text
                label.sizeToFit()
                return
            }

            remove()

            let label = NSTextField(labelWithString: text)
            label.font = .monospacedDigitSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
            label.textColor = .secondaryLabelColor
            label.isBordered = false
            label.isBezeled = false
            label.drawsBackground = false
            label.toolTip = "应用版本信息"
            label.setAccessibilityLabel("应用版本 \(text)")
            label.sizeToFit()

            let accessoryController = NSTitlebarAccessoryViewController()
            accessoryController.view = label
            accessoryController.layoutAttribute = .right
            window.addTitlebarAccessoryViewController(accessoryController)

            self.window = window
            self.accessoryController = accessoryController
        }

        func remove() {
            guard let accessoryController,
                  let window,
                  let index = window.titlebarAccessoryViewControllers.firstIndex(where: { $0 === accessoryController })
            else {
                self.window = nil
                self.accessoryController = nil
                return
            }

            window.removeTitlebarAccessoryViewController(at: index)
            self.window = nil
            self.accessoryController = nil
        }
    }
}
