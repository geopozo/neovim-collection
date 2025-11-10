// swift-tools-version:5.3

import Foundation
import PackageDescription

var sources = ["src/parser.c"]
if FileManager.default.fileExists(atPath: "src/scanner.c") {
    sources.append("src/scanner.c")
}

let package = Package(
    name: "TreeSitterMultipart",
    products: [
        .library(name: "TreeSitterMultipart", targets: ["TreeSitterMultipart"]),
    ],
    dependencies: [
        .package(name: "SwiftTreeSitter", url: "https://github.com/tree-sitter/swift-tree-sitter", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "TreeSitterMultipart",
            dependencies: [],
            path: ".",
            sources: sources,
            resources: [
                .copy("queries")
            ],
            publicHeadersPath: "bindings/swift",
            cSettings: [.headerSearchPath("src")]
        ),
        .testTarget(
            name: "TreeSitterMultipartTests",
            dependencies: [
                "SwiftTreeSitter",
                "TreeSitterMultipart",
            ],
            path: "bindings/swift/TreeSitterMultipartTests"
        )
    ],
    cLanguageStandard: .c11
)
