// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "webview_cookie_manager",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "webview-cookie-manager", targets: ["webview_cookie_manager"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "webview_cookie_manager",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
