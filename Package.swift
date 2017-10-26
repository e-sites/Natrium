// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Natrium",
    products: [
        .executable(name: "natrium", targets: ["Natrium"])
    ],
    dependencies: [
        .package(url: "https://github.com/jatoben/CommandLine.git", from: "3.0.0-pre1"),
        .package(url: "https://github.com/behrang/YamlSwift.git", .upToNextMinor(from: "3.4.0")),
        .package(url: "https://github.com/basvankuijck/XcodeEdit.git", .upToNextMinor(from: "1.3.0"))
    ],
    targets: [
        .target(
            name: "Natrium",
            dependencies: [ "CommandLine", "Yaml", "XcodeEdit" ],
            path: ".",
            sources: ["Sources"]
        )
    ]
)
