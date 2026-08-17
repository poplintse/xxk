# CAP-CONFLICT-WARNINGS

Status: candidate

Type: Shared Optional Capability

Introduced From: macOS 0.1 实现

## Purpose

帮助用户发现时间上无法同时执行的已安排事项，减少计划遗漏。

## Business Behavior

- 当两个有效已安排时间区间重叠时，它们都可被标记为冲突。
- 冲突提示只提供信息，不自动移动、删除或拒绝用户的安排。
- 客户端可允许用户关闭视觉提示。

## Rules

- 冲突基于真实时间区间相交，不基于界面中的卡片位置。
- 一个事项的结束正好等于另一事项开始时，不算重叠。
- 无效或待安排事项不参与冲突计算。

## Data

只需要事项身份及其有效开始、结束时间。冲突状态是派生结果，不应作为独立业务事实持久化。

## API / Contract

当前无 API。是否在服务端统一计算冲突尚未评估。

## Edge Cases

- 一个长事项与多个短事项重叠时，所有参与重叠的事项都应被标记。
- 跨日和跨夏令时区间仍按实际时刻判定。
- 某些事项可能允许并行；是否需要“允许重叠”语义尚未定义。

## Client Implementations

| Client | Status | Notes |
|---|---|---|
| macOS | implemented | 当前业务行为已验证；见 [macOS Client](../clients/macos.md) |
| iOS | not-evaluated | 能力范围和实现尚未评估；见 [iOS Client](../clients/ios.md) |
| Android | not-evaluated | 能力范围和实现尚未评估；见 [Android Client](../clients/android.md) |
| Windows | not-evaluated | 能力范围和实现尚未评估；见 [Windows Client](../clients/windows.md) |

## Source

从 macOS `ScheduleEngine.conflictingItemIDs` 、规划设置和冲突测试中抽象。原始产品需求没有明确要求，因此保持 `candidate`。

## Promotion Condition

当第二个客户端也需要与界面无关的时间冲突识别语义，或产品明确确认冲突提示是跨客户端默认能力时，重新评估是否提升为 `active`。提升前还需要明确允许重叠事项的业务语义，以及冲突由客户端还是服务端计算。

## Related Capabilities

- [CAP-SCHEDULE-PLANNING](schedule-planning.md)
