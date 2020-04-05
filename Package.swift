// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DancingLinks",
    products: [
        .library(
            name: "DancingLinks",
            targets: ["DancingLinks"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mcmtilman/Common.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DancingLinks",
            dependencies: ["Common"]),
        .testTarget(
            name: "DancingLinksTests",
            dependencies: ["DancingLinks", "Common"]),
    ]
)
