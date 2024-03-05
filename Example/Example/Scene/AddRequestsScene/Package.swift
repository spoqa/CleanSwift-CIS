// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AddRequestsScene",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "AddRequestsScene",
            targets: ["AddRequestsScene"]
        ),
    ],
    dependencies: [
        .package(path: "../Core/NetworkService")
    ],
    targets: [
        .target(
            name: "AddRequestsScene",
            dependencies: [
                .product(name: "NetworkService", package: "NetworkService")
            ]
        ),
        .testTarget(
            name: "AddRequestsSceneTests",
            dependencies: [
                "AddRequestsScene"
            ]
        ),
    ]
)
