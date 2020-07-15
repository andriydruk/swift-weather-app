//
//  SwiftWeatherApp.swift
//  Shared
//
//  Created by Andrius Shiaulis on 04.07.2020.
//

import SwiftUI
import WeatherCore

@main
struct SwiftWeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        // Example of WeatherCore usage
        let provider = MetaWeatherProvider()
        provider.searchLocations(query: "San") { locations, error in
            if let error = error {
                NSLog("Error: %s", error.localizedDescription)
                return
            }
            locations?.forEach {
                NSLog($0.title)
            }
        }
    }
}
