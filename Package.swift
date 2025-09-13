// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "swift-wcwidth",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "Wcwidth",
            targets: ["Wcwidth"]
        ),
        .executable(
          name: "generate",
          targets: ["Generate"]
        ),
    ],
    targets: [
        .target(
            name: "Wcwidth"
        ),
        .executableTarget(
          name: "Generate"
        ),
        .testTarget(
            name: "WcwidthTests",
            dependencies: ["Wcwidth"]
        ),
    ]
)
