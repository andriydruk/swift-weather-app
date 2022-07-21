//
//  SwiftWeatherApp.swift
//  Shared
//
//  Created by Andrius Shiaulis on 04.07.2020.
//

import SwiftUI
import WeatherCore

@main
struct SwiftWeatherApp: App, LocationWeatherViewModelDelegate, LocationSearchDelegate {

    let container = WeatherCoreContainer.createContainer(basePath: Bundle.main.bundlePath)
    
    var weatherViewModel: LocationWeatherViewModel?
    var searchViewModel: LocationSearchViewModel?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        weatherViewModel = container.resolve(LocationWeatherViewModel.self, argument: self)
        searchViewModel = container.resolve(LocationSearchViewModel.self, argument: self)
    }
    
    func onWeatherStateChanged(state: [LocationWeatherData]) {
        
    }
    
    func onSuggestionStateChanged(state: [Location]) {
        
    }
    
    func onError(errorDescription: String) {
        NSLog("Error: %s", errorDescription)
    }
}
