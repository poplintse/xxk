# Decision: macOS 实现是证据，不是跨客户端需求

## Context

macOS 是当前唯一已完成客户端，其中同时包含已验证业务行为、桌面 UI 选择和 SwiftUI/AppKit 实现细节。如果其他客户端直接把 macOS 代码当作需求，会把桌面交互和当前数据模型误当为产品契约。

## Decision

新客户端按 Product Capability、Capability Matrix、目标 Client 文档、API/数据契约、已实现代码的顺序获取需求。macOS 代码只是最后的行为和实现参考。

## Reason

业务语义应跨平台稳定，但导航、布局、拖放、右键菜单、快捷键和系统集成必须适应各平台。

## Consequences

- 从 macOS 新发现的业务能力默认为 `candidate`，不自动传播。
- 开发其他客户端前需先更新 Matrix 和目标 Client 文档。
- 客户端 UI 可不同，但已接受 Capability 中的业务规则不得在无决策记录时分叉。
