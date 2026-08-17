# CAP-SCHEDULE-PLANNING

Status: active

Type: Product Capability

Introduced From: 原始产品需求；由 macOS 0.1 验证

## Purpose

把待安排事项转换为具体、可调整、可执行的旅行时间计划。

## Business Behavior

- 用户可以为事项设置开始和结束时间。
- 用户可以移动已安排事项的日期或时间，并在移动时保持其持续时长。
- 用户可以调整事项的开始或结束，也可将已安排事项恢复为待安排。
- 事项可以跨越日界线，且跨日期间仍是同一事项。

## Rules

- 已安排事项必须同时具有开始和结束，且结束必须晚于开始。
- 排期计算使用所属旅行时区。
- 移动事项时保持持续时长；调整边界时更新持续时长。
- 时间吸附粒度和交互方式是客户端实现选择，不是跨客户端必须相同的业务规则。

## Data

主要业务数据是事项的待安排/已安排状态、开始时间、结束时间和持续时长。

## API / Contract

当前没有跨设备排期协议。未来需明确时区、夏令时、并发修改和时间精度的契约语义。

## Edge Cases

- 跨午夜或跨多日事项需保持单一身份，各日显示只是派生表示。
- 在夏令时变化日移动日期时，应保持预期的当地时间语义。
- 调整后仍必须保持正持续时长。
- 旅行日期范围外是否允许排期尚未定义。

## Client Implementations

| Client | Status | Notes |
|---|---|---|
| macOS | implemented | 当前业务行为已验证；见 [macOS Client](../clients/macos.md) |
| iOS | not-evaluated | 能力范围和实现尚未评估；见 [iOS Client](../clients/ios.md) |
| Android | not-evaluated | 能力范围和实现尚未评估；见 [Android Client](../clients/android.md) |
| Windows | not-evaluated | 能力范围和实现尚未评估；见 [Windows Client](../clients/windows.md) |

## Source

最初来自“每天 24 小时排列，把事项放到想安排的时间，并手工调整时间跨度”的产品需求。

## Related Capabilities

- [CAP-TRIP-ITEMS](trip-items.md)
- [CAP-LODGING-SCHEDULE](lodging-schedule.md)
- [CAP-CONFLICT-WARNINGS](conflict-warnings.md)
- [CAP-MONTH-OVERVIEW](month-overview.md)
- [CAP-ITINERARY-DETAILS](itinerary-details.md)
