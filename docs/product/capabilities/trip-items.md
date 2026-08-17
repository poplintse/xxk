# CAP-TRIP-ITEMS

Status: active

Type: Product Capability

Introduced From: 原始产品需求；由 macOS 0.1 验证

## Purpose

让用户在安排时间之前先收集和完善旅行中必须或想要完成的事项。

## Business Behavior

- 用户可在一次旅行中创建、查看、修改和删除事项。
- 事项可以保持“待安排”，也可关联具体开始和结束时间。
- 事项可记录类型、优先级、预计时长、地点、路线、预计费用、币种、具体内容和重点注意事项。

## Rules

- 事项名称不能为空，每个事项只属于一次旅行。
- 当前类型词汇为游玩参观、住宿、交通、餐饮、购物和其他；这个词汇可在产品验证后调整。
- 当前优先级语义是“必须”和“想去”，不隐含自动排序或调度。
- 删除事项会删除其时间、路线、费用和内容信息。

## Data

主要数据包括事项身份、所属旅行、名称、类型、优先级、时长估计、地点/路线、费用/币种、详情、重点事项和排期状态。

## API / Contract

当前没有稳定的事项 API 或跨客户端 Schema。类型、优先级和币种的协议表示需在引入同步前明确。

## Edge Cases

- 金额为空、负数或极大值时需保证数据安全；当前 macOS 将无效或负数输入处理为零。
- 长标题、空路线、空详情和空重点事项均是有效情况。
- 把已安排事项恢复为待安排时，不应删除其他业务信息。

## Client Implementations

| Client | Status | Notes |
|---|---|---|
| macOS | implemented | 当前业务行为已验证；见 [macOS Client](../clients/macos.md) |
| iOS | not-evaluated | 能力范围和实现尚未评估；见 [iOS Client](../clients/ios.md) |
| Android | not-evaluated | 能力范围和实现尚未评估；见 [Android Client](../clients/android.md) |
| Windows | not-evaluated | 能力范围和实现尚未评估；见 [Windows Client](../clients/windows.md) |

## Source

最初来自“列出必须或想做的游玩、参观、住宿或其他事情，统一定义为事项”的产品需求。

## Related Capabilities

- [CAP-TRIP-MANAGEMENT](trip-management.md)
- [CAP-SCHEDULE-PLANNING](schedule-planning.md)
- [CAP-LODGING-SCHEDULE](lodging-schedule.md)
- [CAP-ITINERARY-DETAILS](itinerary-details.md)
