// swift-tools-version: 5.9
import PackageDescription

let package_confuse = Package(
    name: "ConfuseDesktop_confuse",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ConfuseDesktop_confuse", targets: ["ConfuseDesktop_confuse"])
    ],
    targets: [
        .executableTarget(
            name: "ConfuseDesktop_confuse",
            resources: [.copy("Resources")]
        )
    ]
)
