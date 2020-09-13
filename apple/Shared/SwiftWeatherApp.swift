//
//  SwiftWeatherApp.swift
//  Shared
//
//  Created by Andrius Shiaulis on 04.07.2020.
//

import SwiftUI
import WeatherCore

@main
struct SwiftWeatherApp: App, LocationWeatherViewModelDelegate {

    let container = WeatherCoreContainer(basePath: Bundle.main.bundlePath)
    
    var viewModel: LocationWeatherViewModel?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        viewModel = container.getWeatherViewModel(delegate: self)
    }
    
    func onSearchSuggestionChanged(locations: [Location]) {
        
    }
    
    func onSavedLocationChanged(locations: [Location]) {
    
    }
    
    func onWeatherStateChanged(state: [LocationWeatherData]) {
        
    }
    
    func onError(errorDescription: String) {
        NSLog("Error: %s", errorDescription)
    }
}
