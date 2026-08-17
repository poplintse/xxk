# iOS Client

## Role

未来的移动触控客户端。其首要任务应由当时最重要的移动旅行场景决定，不是把 macOS 窗口和时间轴缩小到手机屏幕。

## Implemented Capabilities

暂无；iOS 工程尚未建立。

## Partial Capabilities

暂无。

## Planned Capabilities

尚未批准具体 Capability 范围。开始实施前应从 Matrix 的 `not-evaluated` 状态逐项评估。

## Unsupported Capabilities

暂无明确不支持项。

## Client-specific Features

暂无已确认的 iOS 专属功能。Widget、Share Extension、Live Activity、App Intent 和生物识别均不因为平台可用就自动进入需求。

## Implementation Notes

- `apps/ios` 当前只有范围说明，没有工程或技术栈决策。
- 可在出现真实共享用例后评估 `packages/apple-shared`，不提前抽取 macOS 模型或视图代码。
