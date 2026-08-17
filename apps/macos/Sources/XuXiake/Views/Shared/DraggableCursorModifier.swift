import AppKit
import SwiftUI

extension View {
    func draggableCursor(isEnabled: Bool = true) -> some View {
        modifier(DraggableCursorModifier(isEnabled: isEnabled))
    }

    func verticalResizeCursor(isDragging: Bool) -> some View {
        modifier(VerticalResizeCursorModifier(isDragging: isDragging))
    }
}

private struct DraggableCursorModifier: ViewModifier {
    let isEnabled: Bool
    @State private var cursorController = GrabCursorController()

    func body(content: Content) -> some View {
        content
            .onHover { isHovering in
                if isEnabled {
                    cursorController.setHovering(isHovering)
                }
            }
            .onChange(of: isEnabled) { _, isEnabled in
                if !isEnabled {
                    cursorController.stop()
                }
            }
            .onDisappear {
                cursorController.stop()
            }
    }
}

private struct VerticalResizeCursorModifier: ViewModifier {
    let isDragging: Bool
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .onHover { isHovering in
                self.isHovering = isHovering
                updateCursor()
            }
            .onChange(of: isDragging) { _, _ in
                updateCursor()
            }
            .onDisappear {
                if isHovering || isDragging {
                    NSCursor.arrow.set()
                }
            }
    }

    private func updateCursor() {
        if isHovering || isDragging {
            NSCursor.resizeUpDown.set()
        } else {
            NSCursor.arrow.set()
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
