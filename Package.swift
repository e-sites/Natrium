// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Natrium",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "natrium", targets: ["Natrium"])
    ],
    dependencies: [
        .package(url: "https://github.com/basvankuijck/CommandLine.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/behrang/YamlSwift.git", .upToNextMajor(from: "3.4.0")),
        .package(url: "https://github.com/basvankuijck/XcodeEdit.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/e-sites/Francium.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "Natrium",
            dependencies: [ "CommandLineKit", "Yaml", "XcodeEdit", "Francium" ],
            path: ".",
            sources: ["Sources"]
        )
    ]
)
