# CAP-MONTH-OVERVIEW

Status: active

Type: Product Capability

Introduced From: 原始产品需求；由 macOS 0.1 验证

## Purpose

让用户在较长时间范围内快速了解哪些日期已有安排，并定位到某个具体日期继续规划。

## Business Behavior

- 用户可以按月查看已安排事项的日期分布。
- 跨日事项在所覆盖的每个日期都应被看见。
- 用户可从某个日期进入更具体的时间规划上下文。

## Rules

- 日期归属按旅行时区计算。
- 月度概览是对同一份计划数据的派生表示，不创建独立事项副本。
- 某日的显示上限、排版形式和导航交互由客户端决定。

## Data

该能力只需要已安排事项的时间区间、标题、类型和旅行时区。每日占用情况是计算结果。

## API / Contract

当前无 API。若未来由服务端提供月度摘要，需明确区间相交和时区语义。

## Edge Cases

- 跨月、跨年和跨时区事项需出现在正确的当地日期。
- 一天中事项过多时，客户端可以摘要显示，但不应改变实际事项数量。
- 待安排事项当前不属于任何月度日期。

## Client Implementations

| Client | Status | Notes |
|---|---|---|
| macOS | implemented | 当前业务行为已验证；见 [macOS Client](../clients/macos.md) |
| iOS | not-evaluated | 能力范围和实现尚未评估；见 [iOS Client](../clients/ios.md) |
| Android | not-evaluated | 能力范围和实现尚未评估；见 [Android Client](../clients/android.md) |
| Windows | not-evaluated | 能力范围和实现尚未评估；见 [Windows Client](../clients/windows.md) |

## Source

最初来自“用月度视图显示简要版本，查看整个月的使用情况”的产品需求。

## Related Capabilities

- [CAP-SCHEDULE-PLANNING](schedule-planning.md)
- [CAP-LODGING-SCHEDULE](lodging-schedule.md)
- [CAP-ITINERARY-DETAILS](itinerary-details.md)
