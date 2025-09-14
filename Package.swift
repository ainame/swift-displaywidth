// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "swift-displaywidth",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8)
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
