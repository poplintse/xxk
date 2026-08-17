# macOS Client

## Role

当前首个可运行、可测试和可打包的客户端，用于验证旅行事项到可执行时间计划的核心流程。它提供已验证行为证据，但不是 iOS、Android 或 Windows 的完整需求源。

## Implemented Capabilities

- [CAP-TRIP-MANAGEMENT](../capabilities/trip-management.md)
- [CAP-TRIP-ITEMS](../capabilities/trip-items.md)
- [CAP-SCHEDULE-PLANNING](../capabilities/schedule-planning.md)
- [CAP-LODGING-SCHEDULE](../capabilities/lodging-schedule.md)
- [CAP-MONTH-OVERVIEW](../capabilities/month-overview.md)
- [CAP-ITINERARY-DETAILS](../capabilities/itinerary-details.md)
- [CAP-CONFLICT-WARNINGS](../capabilities/conflict-warnings.md) (`candidate`)
- [CAP-LOCAL-OFFLINE](../capabilities/local-offline.md) (`candidate`)

## Partial Capabilities

暂无。Matrix 中的 `done` 基于当前 Capability 语义和现有自动/人工验收，不代表产品已完成 1.0 定义。

## Planned Capabilities

导入导出、iCloud/跨设备同步、提醒、打印和分享均仍是未评估方向，还没有建立正式 Capability。

## Unsupported Capabilities

- 当前不支持账户、远程同步或多人协作。这些尚未形成正式 Capability，因此不应据此推断未来必须支持。
- 当前发布不支持 Intel Mac。这是发布架构约束，不是 Product Capability 差异。

## Client-specific Features

- macOS 标准菜单命令和新建旅行/事项键盘快捷键。
- 旅行侧边栏标题区和空白区域提供新建入口，旅行行通过右键菜单编辑或删除。
- 原生独立 Settings 场景。
- 待安排事项以独立卡片呈现，整张卡片可拖入时间轴，并提供桌面拖放预览。
- 待安排卡片和时间轴事项在悬停、按下及拖动时使用张手/抓手光标反馈。
- 详细行程 Table 与 Inspector 编辑面板。

## Implementation Notes

- Swift 6、SwiftUI、SwiftData，SwiftPM 可执行工程。
- `Trip` 与 `TripItem` 是当前本地模型；不应直接当作未来 API Schema。
- `ScheduleEngine` 是当前客户端对排期、住宿分段和冲突检测的实现。
- 偏好使用 `UserDefaults`，旅行数据使用应用沙盒中的 SwiftData。
- 月历网格、一周时间轴、拖放和视图切换是 macOS Client Implementation，其他客户端可使用不同交互。
- 工作区和规划视图填满可用窗口空间；尺寸约束只用于修复 macOS 布局，不构成产品业务规则。
