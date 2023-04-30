// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "ControlledAnimation",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ControlledAnimation",
            targets: ["ControlledAnimation"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ControlledAnimation",
            dependencies: []
        )
    ]
)
