import AppKit
import SwiftUI

extension View {
    func draggableCursor() -> some View {
        modifier(DraggableCursorModifier())
    }
}

private struct DraggableCursorModifier: ViewModifier {
    @State private var cursorController = GrabCursorController()

    func body(content: Content) -> some View {
        content
            .onHover { isHovering in
                cursorController.setHovering(isHovering)
            }
            .onDisappear {
                cursorController.stop()
            }
    }
}

@MainActor
private final class GrabCursorController {
    private var eventMonitor: Any?
    private var isHovering = false
    private var isPressed = false

    func setHovering(_ isHovering: Bool) {
        self.isHovering = isHovering

        if isHovering {
            startMonitoringIfNeeded()
            (isPressed ? NSCursor.closedHand : NSCursor.openHand).set()
        } else if !isPressed {
            NSCursor.arrow.set()
            stopMonitoring()
        }
    }

    func stop() {
        isHovering = false
        isPressed = false
        NSCursor.arrow.set()
        stopMonitoring()
    }

    private func startMonitoringIfNeeded() {
        guard eventMonitor == nil else { return }

        eventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]
        ) { [weak self] event in
            guard let self else { return event }

            switch event.type {
            case .leftMouseDown, .leftMouseDragged:
                self.isPressed = true
                NSCursor.closedHand.set()
            case .leftMouseUp:
                self.isPressed = false
                if self.isHovering {
                    NSCursor.openHand.set()
                } else {
                    NSCursor.arrow.set()
                    self.stopMonitoring()
                }
            default:
                break
            }

            return event
        }
    }

    private func stopMonitoring() {
        guard let eventMonitor else { return }
        NSEvent.removeMonitor(eventMonitor)
        self.eventMonitor = nil
    }
}
