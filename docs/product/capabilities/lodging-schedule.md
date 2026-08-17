# CAP-LODGING-SCHEDULE

Status: active

Type: Product Capability

Introduced From: 原始产品需求；由 macOS 0.1 验证

## Purpose

让住宿按“入住日期 + 住宿晚数 + 退房时间”的旅行语义正确跨越相邻日期，避免用户为每一晚重复建立事项。

## Business Behavior

- 住宿事项可记录住宿晚数。
- 使用默认住宿时间时，开始为入住日的默认入住时间，结束为相隔指定晚数后的默认退房时间。
- 住宿在每个覆盖日期上都可被查看，但仍是同一业务事项。
- 用户可改为手工时间范围；手工调整后的持续时长在后续移动时保留。

## Rules

- 住宿晚数至少为 1。macOS 当前的 30 晚上限是实现约束，不是已确认的产品上限。
- 默认入住和退房时间可配置，但各客户端的配置界面可以不同。
- 任何住宿的结束必须晚于开始。
- 仅按整天移动默认住宿时，保留默认入退房语义；改变时刻或拉伸边界后转为手工时间。

## Data

主要业务数据是住宿事项、晚数、是否使用默认时间、开始和结束。按日显示的片段是派生数据，不是多个独立住宿记录。

## API / Contract

当前无 API。未来协议需区分默认住宿语义与已固化的手工时间，不能只传输视图上的每日片段。

## Edge Cases

- 退房时刻可以早于入住时刻的钟表值，因为它发生在后续日期。
- 住宿可跨越月份、年份、时区或夏令时边界。
- 修改晚数时，仅对仍使用默认时间的住宿自动重算结束。

## Client Implementations

| Client | Status | Notes |
|---|---|---|
| macOS | implemented | 当前业务行为已验证；见 [macOS Client](../clients/macos.md) |
| iOS | not-evaluated | 能力范围和实现尚未评估；见 [iOS Client](../clients/ios.md) |
| Android | not-evaluated | 能力范围和实现尚未评估；见 [Android Client](../clients/android.md) |
| Windows | not-evaluated | 能力范围和实现尚未评估；见 [Windows Client](../clients/windows.md) |

## Source

最初来自“住宿自动跨越相邻日、多晚自动列到各天、默认入退房可配置并可手工拉动调整”的产品需求。

## Related Capabilities

- [CAP-TRIP-ITEMS](trip-items.md)
- [CAP-SCHEDULE-PLANNING](schedule-planning.md)
- [CAP-MONTH-OVERVIEW](month-overview.md)
