// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AckGen",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v14)
    ],
    products: [
        .executable(name: "ackgen", targets: ["AckGenCLI"]),
        .library(name: "AckGenUI", targets: ["AckGenUI"]),
        .library(name: "AckGen", targets: ["AckGenCore"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "AckGenCLI",
            dependencies: ["AckGenCore"]),
        .target(
            name: "AckGenUI",
            dependencies: ["AckGenCore"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "AckGenCore",
            dependencies: [],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "AckGenTests",
            dependencies: ["AckGenCore"]),
    ]
)
