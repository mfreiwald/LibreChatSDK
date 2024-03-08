// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LibreChatSDK",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10)],
    products: [
        .library(
            name: "LibreChatSDK",
            targets: ["LibreChatSDK"]
        ),
        .executable(
            name: "ChatLine",
            targets: ["ChatLine"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/mfreiwald/RealHTTP", branch: "main")
    ],
    targets: [
        .target(name: "LibreChatSDK", dependencies: [
            .product(name: "RealHTTP", package: "RealHTTP")
        ]),
        .executableTarget(name: "ChatLine", dependencies: ["LibreChatSDK"]),
        .testTarget(name: "LibreChatSDKTests", dependencies: ["LibreChatSDK"]),
    ]
)
