// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "enc-swift",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "enc-swift",
            type: .static,
            targets: ["enc-swift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "SwiftRs", url: "https://github.com/Brendonovich/swift-rs", from: "1.0.5")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "enc-swift",
            dependencies: [.product(name: "SwiftRs", package: "SwiftRs")],
            path: "src")
    ]
)
