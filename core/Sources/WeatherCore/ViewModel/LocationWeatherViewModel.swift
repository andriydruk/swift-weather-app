//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

public protocol LocationWeatherViewModelDelegate {
    func onWeatherStateChanged(state: [LocationWeatherData])
    func onError(errorDescription: String)
}

public struct LocationWeatherData: Codable {
    public let location: Location
    public let weather: Weather?
}

public class LocationWeatherViewModel {

    private let provider: WeatherProvider
    private let db: WeatherDatabase
    private let delegate: LocationWeatherViewModelDelegate

    private let dbQueue = OperationQueue()

    private var stateLock = NSLock()
    private var state = [Int64: LocationWeatherData]()

    init(db: WeatherDatabase, provider: WeatherProvider, delegate: LocationWeatherViewModelDelegate) {
        self.db = db
        self.provider = provider
        self.delegate = delegate

        self.dbQueue.maxConcurrentOperationCount = 1
        dbQueue.addOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let locations = strongSelf.db.loadLocations()
            strongSelf.addLocations(locations: locations)
        }
    }

    public func addLocationToSaved(location: Location) {
        dbQueue.addOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.db.addLocation(location)
            strongSelf.addLocations(locations: [location])
        }
    }

    public func removeSavedLocation(location: Location) {
        dbQueue.addOperation { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.db.removeLocation(location)
            strongSelf.removeLocation(woeId: location.woeId)
        }
    }

    private func addLocations(locations: [Location]) {
        modifyState {
            locations.forEach {
                state[$0.woeId] = LocationWeatherData(location: $0, weather: nil)
            }
        }
        locations.forEach {
            weather(withWoeId: $0.woeId)
        }
    }

    private func removeLocation(woeId: Int64) {
        modifyState {
            state[woeId] = nil
        }
    }

    private func updateWeather(woeId: Int64, weather: Weather) {
        modifyState {
            if let oldValue = state.removeValue(forKey: woeId) {
                state[woeId] = LocationWeatherData(location: oldValue.location, weather: weather)
            }
        }
    }

    private func modifyState(block: ()->Void) {
        stateLock.lock()
        block()
        stateLock.unlock()
        let currentState = state.values.sorted(by: { $0.location.title > $1.location.title })
        delegate.onWeatherStateChanged(state: currentState)
    }

    internal func weather(withWoeId woeId: Int64) {
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
                strongSelf.updateWeather(woeId: woeId, weather: weather)
            }
        }
    }

}
