//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation
import JavaCoder

public protocol WeatherRepositoryDelegate {
    func onSearchSuggestionChanged(locations: [Location])
    func onSavedLocationChanged(locations: [Location])
    func onWeatherChanged(woeId: Int64, weather: Weather)
    func onError(errorDescription: String)
}

public class WeatherRepository {

    private let provider: WeatherProvider
    private let db: WeatherDatabase
    private let delegate: WeatherRepositoryDelegate

    private let dbQueue = OperationQueue()

    public init(db: WeatherDatabase, provider: WeatherProvider, delegate: WeatherRepositoryDelegate) {
        self.db = db
        self.provider = provider
        self.delegate = delegate

        self.dbQueue.maxConcurrentOperationCount = 1
    }

    public func loadSavedLocations() {
        dbQueue.addOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let locations = strongSelf.db.loadLocations()
            strongSelf.delegate.onSavedLocationChanged(locations: locations)
            for location in locations {
                strongSelf.weather(withWoeId: location.woeId)
            }
        }
    }

    public func addLocationToSaved(location: Location) {
        dbQueue.addOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.db.addLocation(location)
            strongSelf.delegate.onSavedLocationChanged(locations: strongSelf.db.loadLocations())
            strongSelf.weather(withWoeId: location.woeId)
        }
    }

    public func removeSavedLocation(location: Location) {
        dbQueue.addOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.db.removeLocation(location)
            strongSelf.delegate.onSavedLocationChanged(locations: strongSelf.db.loadLocations())
        }
    }

    public func searchLocations(query: String?) {
        self.provider.searchLocations(query: query) { [weak self] locations, error in
            guard let strongSelf = self else {
                return
            }
            if let error = error {
                strongSelf.delegate.onError(errorDescription: error.localizedDescription)
            }
            else if let locations = locations {
                strongSelf.delegate.onSearchSuggestionChanged(locations: locations)
            }
        }
    }

    public func weather(withWoeId woeId: Int64) {
        // Read from DB

        // Query weather from provider
        self.provider.weather(withWoeId: UInt64(woeId)) { [weak self] weathers, error in
            guard let strongSelf = self else {
                return
            }
            if let error = error {
                strongSelf.delegate.onError(errorDescription: error.localizedDescription)
            }
            else if let weather = weathers?.first {
                strongSelf.delegate.onWeatherChanged(woeId: woeId, weather: weather)
            }
        }
    }

}