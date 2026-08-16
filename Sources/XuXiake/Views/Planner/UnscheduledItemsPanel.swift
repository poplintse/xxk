import SwiftUI

struct UnscheduledItemsPanel: View {
    let items: [TripItem]
    let onAdd: () -> Void
    let onEdit: (TripItem) -> Void
    let onDropItemID: (String) -> Bool
    let onDelete: (TripItem) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("待安排事项").font(.headline)
                Spacer()
                Text("\(items.count)").foregroundStyle(.secondary)
                Button(action: onAdd) { Image(systemName: "plus") }
                    .buttonStyle(.borderless)
                    .help("添加事项")
                    .accessibilityLabel("添加事项")
            }
            .padding(12)
            Divider()

            if items.isEmpty {
                ContentUnavailableView(
                    "都已安排",
                    systemImage: "checkmark.circle",
                    description: Text("新增事项，或从时间轴移回待安排区域。")
                )
            } else {
                List(items) { item in
                    UnscheduledItemRow(item: item)
                        .draggable(item.id.uuidString)
                        .onTapGesture(count: 2) { onEdit(item) }
                        .contextMenu {
                            Button("编辑") { onEdit(item) }
                            Button("删除", role: .destructive) { onDelete(item) }
                        }
                        .accessibilityHint("双击编辑，或拖到时间轴进行安排")
                        .accessibilityAction(named: "编辑") { onEdit(item) }
                }
                .listStyle(.inset)
            }
        }
        .contentShape(Rectangle())
        .dropDestination(for: String.self) { itemIDs, _ in
            guard let itemID = itemIDs.first else { return false }
            return onDropItemID(itemID)
        }
    }
}

private struct UnscheduledItemRow: View {
    let item: TripItem

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: item.kind.systemImage)
                .foregroundStyle(item.kind == .lodging ? Color.green : Color.accentColor)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title).lineLimit(2)
                Text(item.kind == .lodging ? "\(item.lodgingNights) 晚 · \(item.priority.title)" : "约 \(item.estimatedMinutes) 分钟 · \(item.priority.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
