// swift-tools-version:5.7
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
    .library(name: "AckGen", targets: ["AckGen"]),
    .plugin(name: "AckGenPlugin", targets: ["AckGenPlugin"]),
    .plugin(name: "AckGenCommandPlugin", targets: ["AckGenCommandPlugin"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "AckGenCLI",
      dependencies: ["AckGen"],
      plugins: ["AckGenPlugin", "AckGenCommandPlugin"]),
    .target(
      name: "AckGenUI",
      dependencies: ["AckGen"]),
    .target(
      name: "AckGen",
      dependencies: []),
    .testTarget(
      name: "AckGenTests",
      dependencies: ["AckGen"]),
    .plugin(
      name: "AckGenPlugin",
      capability: .buildTool(),
      dependencies: ["AckGenCLIBinary"]),
    .plugin(
      name: "AckGenCommandPlugin",
      capability: .command(
        intent: .custom(
          verb: "licence-docs",
          description: "Creates a .plist containing licences of dependencies"
        ),
        permissions: [.writeToPackageDirectory(reason: "Generate Licence Documentation")]),
      dependencies: ["AckGenCLIBinary"]),
    .binaryTarget(
      name: "AckGenCLIBinary",
      path: "Binaries/AckGenCLIBinary.artifactbundle"),
  ]
)
