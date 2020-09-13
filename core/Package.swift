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
    dependencies: [],
    targets: [
        .target(name: "WeatherCore"),
        .testTarget(name: "WeatherCoreTests", dependencies: ["WeatherCore"]),
    ]
)
