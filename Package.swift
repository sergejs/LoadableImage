// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoadableImageView",
    platforms: [
        .macOS(.v12),
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
        .package(url: "https://github.com/sergejs/cache.git", from: "0.0.1"),
        .package(url: "https://github.com/sergejs/http-client.git", from: "0.0.6"),
    ],
    targets: [
        .target(
            name: "LoadableImageView",
            dependencies: [
                .product(name: "Cache", package: "cache"),
                .product(name: "HTTPClient", package: "http-client"),
            ]
        ),
        .testTarget(
            name: "LoadableImageViewTests",
            dependencies: ["LoadableImageView"]
        ),
    ]
)
