// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "___VARIABLE_sceneName___Scene",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "___VARIABLE_sceneName___Scene",
            targets: ["___VARIABLE_sceneName___Scene"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "___VARIABLE_sceneName___Scene",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "___VARIABLE_sceneName___SceneTests",
            dependencies: [
                "___VARIABLE_sceneName___Scene"
            ]
        ),
    ]
)
