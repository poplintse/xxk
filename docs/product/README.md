# 徐霞客产品能力文档

## Product Overview

徐霞客帮助旅行者把“想做和必须做的事”整理成可调整的时间计划，并在旅行过程中统一查看日期、路线、费用、内容和注意事项。产品仍处于探索阶段，当前只有 macOS 客户端完成了可运行验证。

## Development Model

本项目采用渐进式多客户端开发：先在一个客户端验证产品能力，再根据已验证的业务语义开发其他客户端。不先完整设计所有 Feature，也不要求所有客户端同时实现。

某个已实现客户端的功能只能作为：

- 业务理解参考。
- 已验证行为参考。
- UI 和交互参考。

它不能自动视为其他客户端必须实现的需求。开发或评审一个客户端时，按以下优先级查阅：

1. [Product Capability](capabilities/README.md)
2. [Capability Matrix](matrix/capability-matrix.md)
3. [Client-specific 文档](clients/README.md)
4. API 与数据契约
5. 已实现客户端代码

代码只是最后的实现参考，不是产品需求源。

## Classification

- **Product Capability**：跨客户端成立的业务能力，定义产品“能做什么”。
- **Shared Optional Capability**：多个客户端可能需要，但不强制所有客户端实现。
- **Client-specific Feature**：属于某个平台形态的功能或系统集成，不自动传播。
- **Client Implementation**：某客户端对 Capability 的具体 UI、交互和技术实现。
- **Implementation Detail**：框架、存储、视图结构、手势、日志和打包等工程选择。

## Maintenance

- 从单一客户端新发现的业务能力默认从 `candidate` 开始。
- 只有确认它是产品级语义后才升级为 `active`，并在 [Product Decisions](decisions/README.md) 记录重要理由。
- 客户端交付意义明确的能力后，同步更新 Capability、客户端文档和 Matrix。
- [Release 文档](releases/README.md) 只记录已交付内容，不是需求源。

## Current Open Questions

- 旅行开始/结束日期是否应强制限制事项排期范围。
- 事项类型和“必须/想去”优先级是否已是长期稳定词汇。
- 详细行程是否应包含待安排事项。
- 是否需要允许某些事项显式忽略时间冲突。
- 账户、跨设备同步、协作、后端和离线冲突解决的产品范围。
- 混合币种是否只需分类汇总，或者未来需要汇率换算。
- 下一个客户端及其首批 Capability 仍未确定。
