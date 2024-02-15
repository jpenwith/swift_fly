// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "swift_fly",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),
        .package(path: "/Users/me/Downloads/MediaToolSwift"),
//        .package(url: "https://github.com/starkdmi/MediaToolSwift.git", .upToNextMajor(from: "1.1.2"))
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "MediaToolSwift", package: "MediaToolSwift"),
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),

            // Workaround for https://github.com/apple/swift-package-manager/issues/6940
            .product(name: "Vapor", package: "vapor"),
        ])
    ]
)
