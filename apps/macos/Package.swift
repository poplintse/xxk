// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "XuXiake",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "XuXiake", targets: ["XuXiake"])
    ],
    targets: [
        .executableTarget(
            name: "XuXiake",
            path: "Sources/XuXiake"
        ),
        .testTarget(
            name: "XuXiakeTests",
            dependencies: ["XuXiake"],
            path: "Tests/XuXiakeTests"
        )
    ]
)
