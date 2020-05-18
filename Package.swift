// swift-tools-version:5.2

/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import PackageDescription

let package = Package(
    name: "Ink",
    products: [
        .library(name: "Ink", targets: ["Ink"]),
        .executable(name: "ink-cli", targets: ["InkCLI"])
    ],
    targets: [
        .target(name: "Ink"),
        .target(name: "InkCLI", dependencies: ["Ink"]),
        .testTarget(name: "InkTests", dependencies: ["Ink"])
    ]
)
