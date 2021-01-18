// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Natrium",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v10)
    ],
    products: [
        .library(name: "Natrium", targets: ["Natrium"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Natrium",
            dependencies: [  ],
            path: "Natrium",
            exclude: [
                "natrium"
            ],
            sources: ["Sources/"]
        )
    ]
)
