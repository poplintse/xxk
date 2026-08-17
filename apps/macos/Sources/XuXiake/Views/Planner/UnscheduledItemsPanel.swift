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
                    UnscheduledItemCard(item: item)
                        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .draggable(item.id.uuidString) {
                            UnscheduledItemCard(item: item)
                                .frame(width: 220)
                        }
                        .draggableCursor()
                        .onTapGesture(count: 2) { onEdit(item) }
                        .contextMenu {
                            Button("编辑") { onEdit(item) }
                            Button("删除", role: .destructive) { onDelete(item) }
                        }
                        .accessibilityHint("整张卡片都可以拖到时间轴进行安排，双击编辑")
                        .accessibilityAction(named: "编辑") { onEdit(item) }
                        .listRowInsets(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .dropDestination(for: String.self) { itemIDs, _ in
            guard let itemID = itemIDs.first else { return false }
            return onDropItemID(itemID)
        }
    }
}

private struct UnscheduledItemCard: View {
    let item: TripItem
    @State private var isHovering = false

    private let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)

    var body: some View {
        HStack(alignment: .center, spacing: 11) {
            Image(systemName: item.kind.systemImage)
                .font(.title3)
                .foregroundStyle(item.kind == .lodging ? Color.green : Color.accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.body.weight(.medium))
                    .lineLimit(2)
                Text(item.kind == .lodging ? "\(item.lodgingNights) 晚 · \(item.priority.title)" : "约 \(item.estimatedMinutes) 分钟 · \(item.priority.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .background(isHovering ? Color.accentColor.opacity(0.07) : Color.clear, in: shape)
        .overlay {
            shape.stroke(isHovering ? Color.accentColor.opacity(0.65) : Color.secondary.opacity(0.28), lineWidth: 1)
        }
        .shadow(color: .black.opacity(isHovering ? 0.09 : 0.04), radius: isHovering ? 4 : 2, y: 1)
        .onHover { isHovering = $0 }
        .help("拖到右侧规划表进行安排")
    }
}
