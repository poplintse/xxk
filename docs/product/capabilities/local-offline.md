# CAP-LOCAL-OFFLINE

Status: candidate

Type: Shared Optional Capability

Introduced From: macOS 0.1 实现

## Purpose

让用户在没有账户或网络的情况下创建、修改和查看旅行计划。

## Business Behavior

- 本地修改在客户端重启后仍可用。
- 旅行、事项和排期的主要业务数据可在无网络时读写。
- 本地存储失败时，客户端应明确告知用户数据可能无法持久保存。

## Rules

- 离线能力不得隐式创建账户或上传旅行数据。
- 删除旅行的本地级联语义应符合 [CAP-TRIP-MANAGEMENT](trip-management.md)。
- 不同客户端可以选择不支持完整离线模式；该能力不是当前 Core Capability。

## Data

需要在本地保存旅行、事项、排期和必要偏好。具体数据库、文件格式和迁移方式属于客户端实现。

## API / Contract

当前没有同步 API。如果未来加入同步，需另行定义离线修改、冲突解决、删除传播和隐私语义。

## Edge Cases

- 持久化存储无法打开、磁盘写入失败或数据迁移失败。
- 未来开启同步后，旧的本地数据如何加入账户尚未定义。
- Web 或其他受限客户端可能只能提供部分离线能力。

## Client Implementations

| Client | Status | Notes |
|---|---|---|
| macOS | implemented | 当前业务行为已验证；见 [macOS Client](../clients/macos.md) |
| iOS | not-evaluated | 能力范围和实现尚未评估；见 [iOS Client](../clients/ios.md) |
| Android | not-evaluated | 能力范围和实现尚未评估；见 [Android Client](../clients/android.md) |
| Windows | not-evaluated | 能力范围和实现尚未评估；见 [Windows Client](../clients/windows.md) |

## Source

从 macOS 本地优先实现、隐私文档和持久化测试中抽象。其他客户端尚未验证必要性，因此保持 `candidate`。

## Promotion Condition

当第二个客户端也需要在无账户、无网络条件下完整读写旅行计划，并且产品已明确离线数据与未来同步能力的边界时，重新评估是否提升为 `active` Shared Optional Capability。

## Related Capabilities

- [CAP-TRIP-MANAGEMENT](trip-management.md)
- [CAP-TRIP-ITEMS](trip-items.md)
- [Decision 0002](../decisions/0002-local-offline-remains-candidate.md)
