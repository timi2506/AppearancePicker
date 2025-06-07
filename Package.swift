// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "AppearancePicker",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .macCatalyst(.v16),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AppearancePicker",
            targets: ["AppearancePicker"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AppearancePicker",
            dependencies: [],
            path: "Sources/AppearancePicker",
            resources: []
        )
    ]
)