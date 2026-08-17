# CAP-TRIP-MANAGEMENT

Status: active

Type: Product Capability

Introduced From: 原始产品需求；由 macOS 0.1 验证

## Purpose

让用户分别管理多次旅行，并为每次旅行建立统一的日期和时区语境。

## Business Behavior

- 用户可以创建、查看、修改和删除多次独立旅行。
- 每次旅行可记录名称、目的地、开始日期、结束日期和旅行时区。
- 旅行内的日期、时间和日界线以旅行时区为准，而不是当前设备时区。

## Rules

- 旅行名称不能为空。
- 结束日期不得早于开始日期。
- 时区必须是可识别的时区标识。
- 删除旅行会同时删除属于该旅行的事项和计划信息，且当前没有恢复语义。

## Data

主要业务数据是旅行身份、名称、目的地、日期范围、时区和其所属事项。创建时间可用于稳定排序，但不规定各客户端的存储 Schema。

## API / Contract

当前没有后端 API。`contracts/openapi.yaml` 仍是空约定；旅行身份、同步和删除协议尚未定义。

## Edge Cases

- 跨时区旅行在不同设备上必须保持同一旅行日期语义。
- 删除当前正在查看的旅行后，客户端需进入另一可用旅行或无旅行状态。
- 旅行日期范围是否限制事项排期尚未明确；当前 macOS 没有强制限制。

## Client Implementations

| Client | Status | Notes |
|---|---|---|
| macOS | implemented | 当前业务行为已验证；见 [macOS Client](../clients/macos.md) |
| iOS | not-evaluated | 能力范围和实现尚未评估；见 [iOS Client](../clients/ios.md) |
| Android | not-evaluated | 能力范围和实现尚未评估；见 [Android Client](../clients/android.md) |
| Windows | not-evaluated | 能力范围和实现尚未评估；见 [Windows Client](../clients/windows.md) |

## Source

最初来自“增加旅行计划、编辑或删除旅行”的产品需求，并由 macOS `Trip`、旅行编辑和持久化测试验证。

## Related Capabilities

- [CAP-TRIP-ITEMS](trip-items.md)
- [CAP-SCHEDULE-PLANNING](schedule-planning.md)
- [CAP-LOCAL-OFFLINE](local-offline.md)
