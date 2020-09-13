// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "WeatherCore",
    products:[
        .library(
            name: "WeatherCore", 
            targets:["WeatherCore"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Swinject/Swinject", .upToNextMinor(from: "2.6.0")),
        .package(url: "https://github.com/andriydruk/SwinjectAutoregistration", .branch("android"))
    ],
    targets: [
        .target(name: "WeatherCore", dependencies: ["Swinject", "SwinjectAutoregistration"]),
        .testTarget(name: "WeatherCoreTests", dependencies: ["WeatherCore"]),
    ]
)
