import AppKit
import SwiftData
import SwiftUI

@main
struct XuXiakeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var preferences = AppPreferences()
    @State private var errorState: AppErrorState

    private let modelContainer: ModelContainer

    init() {
        let errorState = AppErrorState()
        do {
            modelContainer = try ModelContainer(for: Trip.self, TripItem.self)
        } catch {
            let fallback = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                modelContainer = try ModelContainer(for: Trip.self, TripItem.self, configurations: fallback)
                errorState.present(
                    title: "本地数据库不可用",
                    message: "应用已使用临时存储启动，本次运行的数据不会永久保存。\n\n\(error.localizedDescription)"
                )
            } catch {
                fatalError("无法创建数据容器：\(error.localizedDescription)")
            }
        }
        _errorState = State(initialValue: errorState)
    }

    var body: some Scene {
        WindowGroup("徐霞客", id: "main") {
            ContentView()
                .environment(preferences)
                .environment(errorState)
                .environment(\.locale, Locale(identifier: "zh_CN"))
                .modelContainer(modelContainer)
                .frame(minWidth: 980, minHeight: 680)
        }
        .defaultSize(width: 1280, height: 820)
        .commands {
            XuXiakeCommands()
        }

        Settings {
            SettingsView()
                .environment(preferences)
                .environment(\.locale, Locale(identifier: "zh_CN"))
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var requestedWindowCreation = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        revealMainWindowWhenReady()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        revealMainWindowWhenReady()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { revealMainWindowWhenReady() }
        return true
    }

    private func revealMainWindowWhenReady() {
        for delay in [0.2, 0.8] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard !NSApp.windows.contains(where: \.isVisible) else { return }
                if let mainWindow = NSApp.windows.first(where: \.canBecomeMain) {
                    mainWindow.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                } else if !self.requestedWindowCreation, self.performNewWindowCommand() {
                    self.requestedWindowCreation = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.requestedWindowCreation = false
                    }
                }
            }
        }
    }

    private func performNewWindowCommand() -> Bool {
        guard let item = newWindowMenuItem(in: NSApp.mainMenu), let action = item.action else { return false }
        return NSApp.sendAction(action, to: item.target, from: item)
    }

    private func newWindowMenuItem(in menu: NSMenu?) -> NSMenuItem? {
        guard let menu else { return nil }
        for item in menu.items {
            let modifiers = item.keyEquivalentModifierMask.intersection(.deviceIndependentFlagsMask)
            if item.keyEquivalent.lowercased() == "n", modifiers == .command, item.action != nil, item.isEnabled {
                return item
            }
            if let nested = newWindowMenuItem(in: item.submenu) { return nested }
        }
        return nil
    }
}
