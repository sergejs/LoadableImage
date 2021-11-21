// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoadableImageView",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "LoadableImageView",
            targets: ["LoadableImageView"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sergejs/Cache.git", .branch("main")),
        .package(url: "https://github.com/sergejs/HTTPClient.git", .branch("main")),
        .package(url: "https://github.com/sergejs/ServiceContainer.git", .branch("main")),
    ],
    targets: [
        .target(
            name: "LoadableImageView",
            dependencies: [
                .product(name: "Cache", package: "Cache"),
                .product(name: "HTTPClient", package: "HTTPClient"),
                .product(name: "ServiceContainer", package: "ServiceContainer"),
            ]
        ),
        .testTarget(
            name: "LoadableImageViewTests",
            dependencies: ["LoadableImageView"]
        ),
    ]
)
