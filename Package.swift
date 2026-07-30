// swift-tools-version: 5.9
import PackageDescription

// Exists purely so the Swift sources have a test target. Consumers install this
// library through CocoaPods via ios/ExpoTvosSearch.podspec, which builds every
// file in ios/ including the two excluded here.
//
// ExpoTvosSearchView.swift and ExpoTvosSearchModule.swift import ExpoModulesCore,
// which is only resolvable inside a React Native app build, so they sit outside
// this package. Everything they depend on (the view model, the card, the parsers)
// is here and covered by the tests.
let package = Package(
    name: "ExpoTvosSearchCore",
    platforms: [.tvOS(.v15)],
    products: [
        .library(name: "ExpoTvosSearchCore", targets: ["ExpoTvosSearchCore"])
    ],
    targets: [
        .target(
            name: "ExpoTvosSearchCore",
            path: "ios",
            exclude: [
                "Tests",
                "ExpoTvosSearch.podspec",
                "ExpoTvosSearchView.swift",
                "ExpoTvosSearchModule.swift"
            ]
        ),
        .testTarget(
            name: "ExpoTvosSearchCoreTests",
            dependencies: ["ExpoTvosSearchCore"],
            path: "ios/Tests"
        )
    ]
)
