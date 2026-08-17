# Decision: 本地离线保持 candidate

## Context

macOS 已实现无账户、无网络权限的本地 SwiftData 持久化，但 iOS、Android、Windows、Web 和后端同步模式都尚未定义。

## Decision

将 [CAP-LOCAL-OFFLINE](../capabilities/local-offline.md) 记录为 Shared Optional Capability，状态保持 `candidate`，不提升为所有客户端必须支持的 Core Capability。

## Reason

本地离线对桌面和移动客户端可能很有价值，但不同客户端的存储限制、账户模式和同步需求尚未验证。单一客户端的已实现状态不足以建立跨客户端强制要求。

## Consequences

- macOS 可继续作为离线行为的验证证据。
- 各新客户端需在规划时单独评估 `done`、`partial` 或 `unsupported`。
- 如果未来引入同步，需新的 Capability 或决策定义冲突解决和数据迁移，不直接扩展本地实现细节。
