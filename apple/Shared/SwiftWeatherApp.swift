//
//  SwiftWeatherApp.swift
//  Shared
//
//  Created by Andrius Shiaulis on 04.07.2020.
//

import SwiftUI
import WeatherCore
import Cleanse

@main
struct SwiftWeatherApp: App, LocationWeatherViewModelDelegate, LocationSearchDelegate {

    let factory = try! ComponentFactory.of(WeatherCoreComponent.prepare(withBasePath: Bundle.main.bundlePath)).build(())
    
    var weatherViewModel: LocationWeatherViewModel?
    var searchViewModel: LocationSearchViewModel?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        weatherViewModel = factory.weatherViewModelFactory.build(self)
        searchViewModel = factory.searchViewModelFactory.build(self)
    }
    
    func onWeatherStateChanged(state: [LocationWeatherData]) {
        
    }
    
    func onSuggestionStateChanged(state: [Location]) {
        
    }
    
    func onError(errorDescription: String) {
        NSLog("Error: %s", errorDescription)
    }
}
