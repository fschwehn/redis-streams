// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "redis-streams",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "RedisStreams",
            targets: ["RedisStreams"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.17.0"),
        .package(url: "https://gitlab.com/mordil/RediStack.git", from: "1.0.0-alpha.9"),
    ],
    targets: [
        .target(
            name: "RedisStreams",
            dependencies: [
                "RediStack",
                .product(name: "NIO", package: "swift-nio"),
        ]),
        .testTarget(
            name: "RedisStreamsTests",
            dependencies: ["RedisStreams"]),
    ]
)
