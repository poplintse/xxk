# 徐霞客发布流程

当前发布目标为 Apple Silicon Mac 上的 macOS 14 及以上 Developer ID 直接分发版本，不支持 Intel Mac。应用使用 Hardened Runtime 和 App Sandbox，不申请网络、相机、定位或用户文件访问权限。

## 本地发布候选包

不配置证书时，脚本使用 ad-hoc 签名，用于验证包结构、资源、权限和启动行为：

```bash
./script/build_release.sh
```

输出：

- `dist/release/XuXiake.app`
- `dist/release/XuXiake.zip`
- `dist/release/XuXiake.zip.sha256`

构建完成后会自动运行 `script/verify_release.sh`，检查归档结构、版本元数据、arm64 架构、App Sandbox、Hardened Runtime、签名和校验和。

## 测试版发布

在没有 Developer ID 证书时，可以生成用于受控验收的版本化测试包：

```bash
./script/publish_test_release.sh
```

输出位于 `dist/test/`，包括测试 ZIP、独立 SHA-256 文件和测试者说明。该包默认是 ad-hoc 签名，不能替代 Developer ID 签名及公证的公开稳定版。

## Developer ID 签名

在已安装 Developer ID Application 证书的机器上：

```bash
SIGNING_IDENTITY="Developer ID Application: …" ./script/build_release.sh
```

脚本不会保存证书名称、Apple ID 或密码。

## 公证

先在钥匙串中创建 `notarytool` profile，然后使用 profile 名称：

```bash
NOTARY_PROFILE="xuxiake-notary" ./script/notarize.sh
```

该脚本会先验证 Developer ID 签名和 zip 校验和，拒绝提交 ad-hoc 签名包；随后提交 zip、等待结果、装订公证票据，并通过 `spctl` 验证 Gatekeeper。成功后会重新打包已装订票据的应用并更新 SHA-256 校验文件。

## 发布前检查

1. 更新仓库根目录的 `VERSION`（三段版本号）和 `BUILD_NUMBER`（递增构建号）；打包脚本会验证格式并写入应用元数据。
2. 运行 `swift test`。
3. 使用真实 Developer ID 运行 `build_release.sh`。
4. 检查 `codesign -dvvv --entitlements - dist/release/XuXiake.app`。
5. 运行公证脚本并确认 `spctl` 接受。
6. 在干净的 macOS 14、当前 macOS 版本上分别验证首次启动、数据保存和升级保留数据。
