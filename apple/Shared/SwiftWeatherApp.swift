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

    @StateObject private var viewModel: WeatherViewModel

    init() {
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String ?? ""
        _viewModel = StateObject(wrappedValue: WeatherViewModel(apiKey: apiKey))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
