// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Authenticator",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Authenticator", targets: ["Authenticator"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Authenticator",
            dependencies: [],
            path: "Authenticator"
        )
    ]
)