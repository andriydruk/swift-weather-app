// swift-tools-version:5.0
import Foundation
import PackageDescription

let packageName = "WeatherCoreBridge"

// generated sources integration
let generatedName = "Generated"
let generatedPath = ".build/\(generatedName.lowercased())"

let isSourcesGenerated: Bool = {
    let baseURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
    let generatedURL = baseURL.appendingPathComponent(generatedPath)

    var isDirectory: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: generatedURL.path, isDirectory: &isDirectory)

    return exists && isDirectory.boolValue
}()

func addGenerated(_ products: [Product]) -> [Product] {
    if isSourcesGenerated == false {
        return products
    }

    return products + [
        .library(name: packageName, type: .dynamic, targets: [generatedName])
    ]
}

func addGenerated(_ targets: [Target]) -> [Target] {
    if isSourcesGenerated == false {
        return targets
    }

    return targets + [
        .target(
            name: generatedName,
            dependencies: [
                .byName(name: packageName),
                "java_swift",
                "Java",
                "JavaCoder",
            ],
            path: generatedPath
        )
    ]
}
// generated sources integration end

let package = Package(
    name: packageName,
    products: addGenerated([
    ]),
    dependencies: [
        .package(url: "https://github.com/readdle/java_swift.git", .exact("2.2.2")),
        .package(url: "https://github.com/readdle/swift-java.git", .exact("0.3.0")),
        .package(url: "https://github.com/readdle/swift-java-coder.git", .exact("1.1.0")),
        .package(url: "https://github.com/readdle/swift-anycodable.git", .exact("1.0.3")),
        .package(path: "../../../../../core")
    ],
    targets: addGenerated([
        .target(name: packageName, dependencies: ["AnyCodable", "java_swift", "JavaCoder", "WeatherCore"])
    ])
)
