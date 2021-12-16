// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoadableImageView",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "LoadableImageView",
            targets: ["LoadableImageView"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sergejs/Cache.git", .upToNextMajor(from: "0.2.0")),
        .package(url: "https://github.com/sergejs/HTTPClient.git", .upToNextMajor(from: "0.2.0")),
        .package(url: "https://github.com/sergejs/ServiceContainer.git", .upToNextMajor(from: "0.2.0")),
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
