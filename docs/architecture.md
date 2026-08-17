# 徐霞客架构

## 产品边界

首个 macOS 版本采用本地优先设计。规划、月览和行程表读取同一组 `Trip` 与 `TripItem` 数据；住宿的跨天块由 `ScheduleEngine` 动态计算，不复制持久化记录。

## Monorepo 边界

- `apps/`：各平台客户端；当前只有 `apps/macos` 是可构建工程。
- `services/`：后端服务；尚未选型。
- `packages/`：有真实多消费者后才提取的共享包。
- `contracts/`：未来跨端 API 契约源。
- `product/` 与 `docs/`：产品探索材料和已稳定文档。

## macOS 模块

- `App/`：应用入口、主窗口和设置场景。
- `Models/`：SwiftData 模型与稳定枚举。
- `Views/`：主工作区、规划时间轴、月览、行程表和编辑器。
- `Support/`：设置、日期金额格式化与日程计算。
- `Stores/`：应用级错误状态与持久化失败呈现。
- `apps/macos/Tests/`：不依赖界面的日程和住宿规则测试。

## 状态所有权

- 应用级偏好：`AppPreferences`，写入 `UserDefaults`。
- 窗口级旅行和视图选择：`@SceneStorage`。
- 旅行、事项和计划：SwiftData。
- 编辑器草稿：视图局部 `@State`。

## 发布方向

当前使用 SwiftPM 保持构建轻量和可复现。Debug 运行脚本生成标准 `.app`；Release 流程生成 Apple Silicon arm64 应用，并包含应用图标、App Sandbox、Hardened Runtime、Developer ID 签名入口、公证入口和 zip 发布归档。
