# Capability Matrix

Matrix 只用于快速查看客户端覆盖范围。业务定义以各 Capability 文件为准。

| Capability | macOS | iOS | Android | Windows |
|---|---|---|---|---|
| [CAP-TRIP-MANAGEMENT](../capabilities/trip-management.md) | done | not-evaluated | not-evaluated | not-evaluated |
| [CAP-TRIP-ITEMS](../capabilities/trip-items.md) | done | not-evaluated | not-evaluated | not-evaluated |
| [CAP-SCHEDULE-PLANNING](../capabilities/schedule-planning.md) | done | not-evaluated | not-evaluated | not-evaluated |
| [CAP-LODGING-SCHEDULE](../capabilities/lodging-schedule.md) | done | not-evaluated | not-evaluated | not-evaluated |
| [CAP-MONTH-OVERVIEW](../capabilities/month-overview.md) | done | not-evaluated | not-evaluated | not-evaluated |
| [CAP-ITINERARY-DETAILS](../capabilities/itinerary-details.md) | done | not-evaluated | not-evaluated | not-evaluated |
| [CAP-CONFLICT-WARNINGS](../capabilities/conflict-warnings.md) | done | not-evaluated | not-evaluated | not-evaluated |
| [CAP-LOCAL-OFFLINE](../capabilities/local-offline.md) | done | not-evaluated | not-evaluated | not-evaluated |

Allowed statuses: `done`, `partial`, `planned`, `unsupported`, `not-evaluated`.

`done` 只表示该客户端已实现当前 Capability 语义；它不会把 `candidate` 自动升级为 `active`。
