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

    // Single ordered list as source of truth - protected by stateLock
    private let stateLock = NSLock()
    private var orderedData = [LocationWeatherData]()

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
            strongSelf.stateLock.lock()
            let alreadyExists = strongSelf.orderedData.contains(where: {
                abs($0.location.latitude - location.latitude) < 0.1 &&
                abs($0.location.longitude - location.longitude) < 0.1
            })
            strongSelf.stateLock.unlock()
            if !alreadyExists {
                strongSelf.db.addLocation(location)
                strongSelf.addLocations(locations: [location])
            }
        }
    }

    public func removeSavedLocation(location: Location) {
        NSLog("removeSavedLocation: \(location)")
        dbQueue.addOperation { [weak self] in
            NSLog("removeSavedLocation in dbQueue")
            guard let strongSelf = self else {
                return
            }
            NSLog("removeSavedLocation in dbQueue after guard")
            strongSelf.db.removeLocation(location)
            NSLog("removeSavedLocation in dbQueue after db.removeLocation")
            strongSelf.stateLock.lock()
            NSLog("removeSavedLocation in dbQueue after stateLock.lock")
            strongSelf.orderedData.removeAll(where: { $0.location.woeId == location.woeId })
            NSLog("removeSavedLocation in dbQueue after orderedData.removeAll")
            let snapshot = strongSelf.orderedData
            NSLog("removeSavedLocation in dbQueue after snapshot")
            strongSelf.stateLock.unlock()
            NSLog("removeSavedLocation in dbQueue after stateLock.unlock")
            strongSelf.delegate.onWeatherStateChanged(state: snapshot)
            NSLog("removeSavedLocation in dbQueue after delegate.onWeatherStateChanged")
        }
    }

    private func addLocations(locations: [Location]) {
        stateLock.lock()
        for loc in locations {
            if !orderedData.contains(where: { $0.location.woeId == loc.woeId }) {
                orderedData.append(LocationWeatherData(location: loc, weather: nil))
            }
        }
        let snapshot = orderedData
        stateLock.unlock()
        delegate.onWeatherStateChanged(state: snapshot)

        locations.forEach {
            weather(location: $0)
        }
    }

    private func updateWeather(woeId: Int64, weather: Weather) {
        stateLock.lock()
        if let index = orderedData.firstIndex(where: { $0.location.woeId == woeId }) {
            orderedData[index] = LocationWeatherData(location: orderedData[index].location, weather: weather)
        }
        let snapshot = orderedData
        stateLock.unlock()
        delegate.onWeatherStateChanged(state: snapshot)
    }

    func weather(location: Location) {
        provider.weather(location: location){ [weak self] weather, error in
            guard let strongSelf = self else {
                return
            }
            if let error = error {
                strongSelf.delegate.onError(errorDescription: error.localizedDescription)
            }
            else if let weather = weather {
                strongSelf.updateWeather(woeId: Int64(location.woeId), weather: weather)
            }
        }
    }
}
