# Capability Index

Capability 只描述用户或业务层面有意义的产品能力，不规定某平台的导航、视图、控件、手势或技术栈。

## Status

- `candidate`：从某客户端或新需求中发现，尚未确认为正式跨客户端能力。
- `active`：已确认为产品级能力。
- `deprecated`：已废弃，但历史客户端可能仍有实现。

## File Convention

- 使用稳定的 `CAP-...` ID 和小写连字符文件名；不因为重命名 UI 而改变 ID。
- 每个 Capability 必须包含 Status、Type、Introduced From，以及 Purpose、Business Behavior、Rules、Data、API / Contract、Edge Cases、Client Implementations、Source 和 Related Capabilities。
- `candidate` Capability 还必须包含 Promotion Condition，写明重新评估为 `active` 所需的产品证据或决策条件。
- Client Implementations 使用 `implemented`、`partial`、`planned`、`unsupported` 或 `not-evaluated`；快速覆盖状态与 Matrix 保持一致。
- `Data` 只记录业务意义，不复制数据库 Schema；平台 UI 和技术实现进入 Client 文档。

## Current Capabilities

| Capability | Type | Status | Summary |
|---|---|---|---|
| [CAP-TRIP-MANAGEMENT](trip-management.md) | Product Capability | active | 管理多次旅行及其日期、目的地和时区 |
| [CAP-TRIP-ITEMS](trip-items.md) | Product Capability | active | 管理必须或想做的旅行事项 |
| [CAP-SCHEDULE-PLANNING](schedule-planning.md) | Product Capability | active | 将事项安排到具体时间并调整计划 |
| [CAP-LODGING-SCHEDULE](lodging-schedule.md) | Product Capability | active | 按住宿晚数和入退房语义生成跨天日程 |
| [CAP-MONTH-OVERVIEW](month-overview.md) | Product Capability | active | 按月快速查看已安排事项 |
| [CAP-ITINERARY-DETAILS](itinerary-details.md) | Product Capability | active | 按时间查看路线、费用、内容和重点事项 |
| [CAP-CONFLICT-WARNINGS](conflict-warnings.md) | Shared Optional Capability | candidate | 识别时间重叠并向用户提示 |
| [CAP-LOCAL-OFFLINE](local-offline.md) | Shared Optional Capability | candidate | 无账户和无网络时在本地管理旅行数据 |

## Scope Notes

- 账户、跨设备同步、协作、搜索、提醒、导入导出尚未实现，也没有足够产品定义，因此不为它们创建占位 Capability。
- 拖放、表格、月历网格、右键菜单和键盘快捷键属于客户端实现，不是独立 Product Capability。
