# CAP-ITINERARY-DETAILS

Status: active

Type: Product Capability

Introduced From: 原始产品需求；由 macOS 0.1 验证

## Purpose

为用户提供可按时间执行和查阅的详细行程，将时间、路线、费用、内容和重点注意事项放在同一计划语境中。

## Business Behavior

- 已安排事项可按开始时间顺序查看。
- 每个行程事项可展示时间、事项、路线、详细内容、预计费用和重点事项。
- 在详细行程中修改的事项应立即反映到规划和其他概览，反之亦然。
- 用户可查看已安排事项的预计费用合计。

## Rules

- 当前详细行程只包含已安排事项；待安排事项是否应以附录形式出现尚未明确。
- 时间使用旅行时区。
- 不同币种不自动换算，而是分别汇总，避免在没有汇率来源时产生错误总额。
- 各客户端可根据屏幕与使用场景重新组织信息，但不改变上述业务字段和同步语义。

## Data

需要已安排事项的时间范围、名称、类型、地点、路线、预计费用与币种、详情和重点事项。

## API / Contract

当前无 API。若未来增加共享、导出或服务端报表，需稳定币种、金额精度、时区和字段可选性。

## Edge Cases

- 混合币种旅行必须分币种显示合计。
- 空路线、空内容和空重点事项不阻止事项进入详细行程。
- 跨日事项应保持一个行程实体，而不是因为日期显示而重复计费。

## Client Implementations

| Client | Status | Notes |
|---|---|---|
| macOS | implemented | 当前业务行为已验证；见 [macOS Client](../clients/macos.md) |
| iOS | not-evaluated | 能力范围和实现尚未评估；见 [iOS Client](../clients/ios.md) |
| Android | not-evaluated | 能力范围和实现尚未评估；见 [Android Client](../clients/android.md) |
| Windows | not-evaluated | 能力范围和实现尚未评估；见 [Windows Client](../clients/windows.md) |

## Source

最初来自“详细旅行规划表写清时间、路线、费用、内容和重点事项，与其他视图自动同步”的产品需求。

## Related Capabilities

- [CAP-TRIP-ITEMS](trip-items.md)
- [CAP-SCHEDULE-PLANNING](schedule-planning.md)
- [CAP-MONTH-OVERVIEW](month-overview.md)
