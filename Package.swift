// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "notsora",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "notsora",
            path: "notsora",
            exclude: [
                "Resources/Assets.xcassets",
                "notsora.entitlements"
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
