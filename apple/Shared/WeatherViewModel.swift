//
//  WeatherViewModel.swift
//  Shared
//

import Foundation
import WeatherCore
import Combine

final class WeatherViewModel: ObservableObject, LocationWeatherViewModelDelegate, LocationSearchDelegate {

    // MARK: - Published State

    @Published var locations: [LocationWeatherData] = []
    @Published var suggestions: [LocationWeatherData] = []
    @Published var errorMessage: String?
    @Published var currentPageIndex: Int = 0

    // MARK: - Core ViewModels

    private let container: WeatherCoreContainer
    private(set) var weatherViewModel: LocationWeatherViewModel?
    private(set) var searchViewModel: LocationSearchViewModel?

    // MARK: - Init

    init(apiKey: String) {
        let basePath = WeatherViewModel.dataDirectoryPath()
        self.container = WeatherCoreContainer(basePath: basePath, apiKey: apiKey)
        self.weatherViewModel = container.getWeatherViewModel(delegate: self)
        self.searchViewModel = container.getLocationSearchViewModel(delegate: self)
    }

    // MARK: - Data Directory

    private static func dataDirectoryPath() -> String {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("SwiftWeather")
        if !fileManager.fileExists(atPath: appDir.path) {
            try? fileManager.createDirectory(at: appDir, withIntermediateDirectories: true)
        }
        return appDir.path
    }

    // MARK: - Actions

    func searchLocations(_ query: String?) {
        searchViewModel?.searchLocations(query: query)
    }

    func addLocation(_ location: Location) {
        weatherViewModel?.addLocationToSaved(location: location)
    }

    func removeLocation(_ location: Location) {
        weatherViewModel?.removeSavedLocation(location: location)
    }

    func findExistingCityIndex(_ location: Location) -> Int? {
        let index = locations.firstIndex(where: {
            abs($0.location.latitude - location.latitude) < 0.1 &&
            abs($0.location.longitude - location.longitude) < 0.1
        })
        return index
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - LocationWeatherViewModelDelegate

    func onWeatherStateChanged(state: [LocationWeatherData]) {
        DispatchQueue.main.async { [weak self] in
            self?.locations = state
        }
    }

    // MARK: - LocationSearchDelegate

    func onSuggestionStateChanged(state: [LocationWeatherData]) {
        DispatchQueue.main.async { [weak self] in
            self?.suggestions = state
        }
    }

    // MARK: - Shared Error Handler

    func onError(errorDescription: String) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = errorDescription
        }
    }
}
