// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Solvy",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SolvyCore",
            targets: ["SolvyCore"]
        ),
        .library(
            name: "SolvyApp",
            targets: ["SolvyApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/web3swift-team/web3swift.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "SolvyCore",
            dependencies: [
                .product(name: "web3swift", package: "web3swift")
            ]
        ),
        .target(
            name: "SolvyApp",
            dependencies: ["SolvyCore"]
        ),
        .testTarget(
            name: "SolvyCoreTests",
            dependencies: ["SolvyCore"]
        )
    ]
)
