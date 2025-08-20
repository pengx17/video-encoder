// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "video-encoder-indexing",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        // A dummy library product so SourceKit-LSP can index the code.
        .library(name: "VideoEncoderKit", targets: ["VideoEncoderKit"])
    ],
    targets: [
        .target(
            name: "VideoEncoderKit",
            path: "video-encoder",
            exclude: [
                "Assets.xcassets",
                "video_encoder.entitlements",
                "video_encoderApp.swift"
            ]
        )
    ]
)


