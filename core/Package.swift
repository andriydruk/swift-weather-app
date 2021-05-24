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
        .package(url: "https://github.com/andriydruk/Cleanse", .branch("master"))
    ],
    targets: [
        .target(name: "WeatherCore", dependencies: ["Cleanse"]),
        .testTarget(name: "WeatherCoreTests", dependencies: ["WeatherCore"]),
    ]
)
