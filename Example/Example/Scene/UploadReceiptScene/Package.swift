// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UploadReceiptScene",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "UploadReceiptScene",
            targets: ["UploadReceiptScene"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/devxoul/Toaster.git", branch: "master"),
        .package(path: "./AddRequestsScene"),
    ],
    targets: [
        .target(
            name: "UploadReceiptScene",
            dependencies: [
                .product(name: "Toaster", package: "Toaster"),
                .product(name: "AddRequestsScene", package: "AddRequestsScene")
            ]
        ),
        .testTarget(
            name: "UploadReceiptSceneTests",
            dependencies: [
                "UploadReceiptScene"
            ]
        ),
    ]
)
