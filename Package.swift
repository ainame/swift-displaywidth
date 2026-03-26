// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-displaywidth",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "DisplayWidth",
            targets: ["DisplayWidth"]
        ),
        .executable(
          name: "generate",
          targets: ["Generate"]
        ),
    ],
    targets: [
        .target(
            name: "DisplayWidth"
        ),
        .executableTarget(
          name: "Generate"
        ),
        .testTarget(
            name: "DisplayWidthTests",
            dependencies: ["DisplayWidth"]
        ),
    ]
)
