// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "ConcurrencyPlus",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(name: "ConcurrencyPlus", targets: ["ConcurrencyPlus"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "ConcurrencyPlus", dependencies: []),
        .testTarget(name: "ConcurrencyPlusTests", dependencies: ["ConcurrencyPlus"]),
    ]
)
