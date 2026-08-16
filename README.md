# 徐霞客

徐霞客是一款原生、轻量的 macOS 旅行规划应用。它把待办事项、24 小时时间轴、月览和详细行程表放在同一份本地数据之上。

## 当前功能

- 创建多次旅行并设置日期、目的地和旅行时区。
- 管理游玩、住宿、交通、餐饮、购物和其他事项。
- 把未安排事项拖入一周 24 小时时间轴，并拖动边缘调整时间。
- 直接拖动已安排时间块，在日期之间重新排期并保持原持续时间。
- 自动计算多晚住宿的入住、跨天和退房片段。
- 显示时间冲突，并支持把事项移回待安排列表。
- 月览双击日期跳转到对应规划周。
- 在详细行程表中编辑时间、路线、费用、内容和重点事项。
- 使用独立 macOS 设置窗口配置住宿时间、时间轴和默认币种。
- SwiftData 本地持久化；不需要账户或网络。

## 开发

要求 macOS 14+、Xcode 26 或兼容的 Swift 6 工具链。

```bash
swift test
./script/build_and_run.sh
```

Codex 桌面应用的 Run 动作已连接到 `script/build_and_run.sh`。

## 发布候选包

```bash
./script/build_release.sh
```

脚本生成 Apple Silicon arm64、Hardened Runtime、App Sandbox 的 `.app` 和 zip。Developer ID 签名与公证参见 [docs/release.md](docs/release.md)。
版本号与构建号分别由根目录的 `VERSION`、`BUILD_NUMBER` 管理；打包结束时会自动运行 `script/verify_release.sh` 验证实际 ZIP 中的应用。

## 发布测试版

```bash
./script/publish_test_release.sh
```

脚本会重新构建并验证应用，然后在 `dist/test/` 生成带版本号的 Apple Silicon 测试 ZIP、SHA-256 校验文件和测试者说明。测试版默认使用 ad-hoc 签名，仅用于受控测试。

## 文档

- [架构](docs/architecture.md)
- [发布流程](docs/release.md)
- [隐私说明](docs/privacy.md)
- [路线图](docs/roadmap.md)
- [视觉资源](docs/assets.md)
- [发布质量状态](docs/quality.md)
