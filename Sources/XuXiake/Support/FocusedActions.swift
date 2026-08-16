import SwiftUI

struct NewTripAction {
    let perform: () -> Void
}

struct NewItemAction {
    let perform: () -> Void
}

private struct NewTripActionKey: FocusedValueKey {
    typealias Value = NewTripAction
}

private struct NewItemActionKey: FocusedValueKey {
    typealias Value = NewItemAction
}

extension FocusedValues {
    var newTripAction: NewTripAction? {
        get { self[NewTripActionKey.self] }
        set { self[NewTripActionKey.self] = newValue }
    }

    var newItemAction: NewItemAction? {
        get { self[NewItemActionKey.self] }
        set { self[NewItemActionKey.self] = newValue }
    }
}

struct XuXiakeCommands: Commands {
    @FocusedValue(\.newTripAction) private var newTripAction
    @FocusedValue(\.newItemAction) private var newItemAction

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("新建旅行") { newTripAction?.perform() }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                .disabled(newTripAction == nil)
            Button("新建事项") { newItemAction?.perform() }
                .keyboardShortcut("n", modifiers: [.command, .option])
                .disabled(newItemAction == nil)
        }
    }
}
