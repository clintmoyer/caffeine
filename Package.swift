// swift-tools-version:5.9
import PackageDescription

let package = Package(
	name: "Caffeine",
	platforms: [
		.macOS(.v13)
	],
	products: [
		.executable(name: "Caffeine", targets: ["Caffeine"])
	],
	targets: [
		.executableTarget(
			name: "Caffeine",
			dependencies: [],
			linkerSettings: [
				.linkedFramework("Cocoa"),
				.linkedFramework("IOKit")
			]
		),
		.testTarget(
			name: "CaffeineTests",
			dependencies: ["Caffeine"]
		)
	]
)
