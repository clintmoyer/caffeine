// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Caffeine",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "Caffeine", targets: ["caffeine"]),
    ],
    targets: [
        .executableTarget(
            name: "caffeine",
            dependencies: [],
            path: "Sources/caffeine"
        ),
        .testTarget(
            name: "caffeineTests",
            dependencies: ["caffeine"],
            path: "Tests/caffeineTests"
        ),
    ]
)
