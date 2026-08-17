# 徐霞客路线图

## macOS 1.0

- 完整旅行和事项管理。
- 一周 24 小时拖放时间轴。
- 多晚住宿跨天计算和手动调整。
- 月览、详细行程表与三视图同步。
- 本地持久化、设置、键盘和 VoiceOver 支持。
- Apple Silicon arm64、Developer ID 签名与公证发布。

## 后续 macOS 版本

- 可选导入和导出格式。
- 可选 iCloud 同步。
- 更完善的打印与分享布局。

## iOS

开始 iOS 实施前，先根据 `docs/product/capabilities/`、Capability Matrix 和 iOS Client 文档确定本期范围。macOS 模型与 `ScheduleEngine` 只能用于理解已验证行为，不是 iOS 的直接规格。出现真实的多端共享用例后，再决定是否提取共享 Swift 包；iOS 规划交互应针对触控和窄屏重新设计。
