# 徐霞客 Monorepo

徐霞客是一个处于产品探索阶段的跨平台旅行规划项目。仓库为 Android、iOS、macOS、Windows 客户端和后端预留了清晰边界，但不在需求确定前锁定未来平台的技术栈。

当前只有 macOS 客户端已实现：它是原生、本地优先的 SwiftUI/SwiftData 应用，支持待安排事项、一周 24 小时时间轴、月览、详细行程表和跨天住宿。

## 仓库结构

```text
apps/                  客户端
  android/             Android（待选型）
  ios/                 iOS（待选型）
  macos/               已实现的 SwiftPM macOS 应用
  windows/             Windows（待选型）
services/backend/      后端（待选型）
packages/contracts/    未来的契约派生物与共享工具
packages/apple-shared/ iOS/macOS 共享代码（有实际需求后再创建包）
contracts/             跨端 API 契约源
product/               产品探索材料
docs/                  产品、架构、质量与发布文档
scripts/               根级验证与平台脚本
```

## 开发

运行当前所有已配置测试：

```bash
./scripts/test.sh
```

检查基础工具链：

```bash
./scripts/check-env.sh
```

macOS 客户端要求 macOS 14+ 和 Swift 6：

```bash
swift test --package-path apps/macos
./scripts/macos/build_and_run.sh
./scripts/macos/build_release.sh
```

## 文档

- [产品能力体系](docs/product/README.md)
- [产品愿景](docs/VISION.md)
- [当前状态](docs/CURRENT.md)
- [决策记录](docs/DECISIONS.md)
- [架构](docs/architecture.md)
- [发布流程](docs/release.md)
- [隐私说明](docs/privacy.md)
- [路线图](docs/roadmap.md)
- [发布质量状态](docs/quality.md)
