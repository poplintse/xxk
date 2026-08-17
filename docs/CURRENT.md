# 当前状态

> 更新日期：2026-08-17

## 产品

- macOS 客户端是当前唯一已实现产品，采用 SwiftUI、SwiftData 和本地优先存储。
- 统一产品能力定义、客户端覆盖和产品决策位于 `docs/product/`；新客户端不直接以 macOS 代码为需求源。
- Android、iOS、Windows 和后端只有边界目录，没有选定框架或创建空业务结构。
- OpenAPI 文件是无端点占位契约，不表示后端需求已确定。

## 工程

- Git 仓库已初始化，主分支为 `main`，SSH 远端为 `git@github.com:poplintse/xxk.git`。
- 原根目录 SwiftPM 工程已整体迁移到 `apps/macos`，现有未提交界面改动一并保留。
- 根目录 `scripts/test.sh` 是统一测试入口；当前只运行已配置的 macOS 测试。
- macOS 构建、打包、验证和公证脚本位于 `scripts/macos`。

## 已检查的本机工具链

| 领域 | 当前状态 |
| --- | --- |
| Apple | Xcode 26.6，Swift 6.3.3，Apple Silicon |
| Android | JDK 17.0.19，Gradle 9.6.1，ADB 37.0.0，Android 35/36 SDK |
| JavaScript | Node 22.22.3，npm 10.9.8，pnpm 10.33.2 |
| Windows | .NET/MSBuild 未安装；技术栈未选定，当前不是构建阻塞 |
| 容器 | Docker 未安装；后端尚未选型 |
| GitHub | GitHub SSH 已实际认证为 `poplintse`；`gh` 本地 token 失效，不影响 Git SSH，也不影响本次不提交、不推送的迁移 |

## Monorepo 初始化验证

- `scripts/check-env.sh` 通过：Git、`main`、GitHub SSH origin、所有要求的目录与文件、AGENTS 软链接和当前 Apple 工具链均可用。
- `scripts/test.sh` 通过：OpenAPI 占位契约检查通过，macOS 4 个测试套件共 21 项测试全部通过。
- `scripts/macos/build_release.sh` 通过：输出 Apple Silicon arm64、App Sandbox 和 Hardened Runtime 的已验证测试包。
- 迁移过程没有执行暂存、commit 或 push。

## 下一个产品决策点

先确定下一个要验证的用户场景和平台，再创建对应工程。如果需要跨设备数据，先决定同步语义与隐私边界，再设计后端。
