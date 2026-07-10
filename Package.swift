// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-form-coding",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: "FormCoding", targets: ["FormCoding"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-url-form-coding.git", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-multipart-form-coding.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-7578", branch: "main"),
        .package(url: "https://github.com/swift-foundations/swift-url-routing.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "FormCoding",
            dependencies: [
                .product(name: "URLFormCoding", package: "swift-url-form-coding"),
                .product(name: "MultipartFormCoding", package: "swift-multipart-form-coding"),
            ]
        ),
        .testTarget(
            name: "FormCoding Tests",
            dependencies: ["FormCoding"]
        )
    ]
)

for target in package.targets {
    target.swiftSettings?.append(
        contentsOf: [
            .enableUpcomingFeature("MemberImportVisibility")
        ]
    )
}

//package.traits.insert(
//    .default(
//        enabledTraits: ["URLRouting"]
//    )
//)

