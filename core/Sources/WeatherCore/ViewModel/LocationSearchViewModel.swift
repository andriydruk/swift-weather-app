//
// Created by Andriy Druk on 01.09.2020.
//

import Foundation
import Dispatch

public protocol LocationSearchDelegate {
    func onSuggestionStateChanged(state: [LocationWeatherData])
    func onError(errorDescription: String)
}

private let DEFAULT_TIMEOUT_REQUEST = 0.2 // 200ms debounce
private let MIN_QUERY_LENGTH = 2

public class LocationSearchViewModel {

    private let provider: WeatherProvider
    private let delegate: LocationSearchDelegate

    private var dispatchWorkItem: DispatchWorkItem?

    init(provider: WeatherProvider, delegate: LocationSearchDelegate) {
        self.provider = provider
        self.delegate = delegate
    }

    public func searchLocations(query: String?) {
        self.dispatchWorkItem?.cancel()
        guard let query = query, query.count >= MIN_QUERY_LENGTH else {
            delegate.onSuggestionStateChanged(state: [])
            return
        }
        dispatchWorkItem = DispatchWorkItem(block: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.provider.searchLocations(query: query) { [weak self] locations, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    strongSelf.delegate.onError(errorDescription: error.localizedDescription)
                    return
                }
                guard !locations.isEmpty else {
                    strongSelf.delegate.onSuggestionStateChanged(state: [])
                    return
                }

                // Emit locations immediately without weather
                let initial = locations.map { LocationWeatherData(location: $0, weather: nil) }
                strongSelf.delegate.onSuggestionStateChanged(state: initial)

                // Fetch weather for all locations in parallel
                let group = DispatchGroup()
                var weatherResults = [Int64: Weather]()
                let lock = NSLock()

                for location in locations {
                    group.enter()
                    strongSelf.provider.weather(location: location) { weather, _ in
                        defer { group.leave() }
                        if let weather = weather {
                            lock.lock()
                            weatherResults[location.woeId] = weather
                            lock.unlock()
                        }
                    }
                }

                group.notify(queue: .global()) { [weak self] in
                    guard let strongSelf = self else { return }
                    let enriched = locations.map { loc in
                        LocationWeatherData(location: loc, weather: weatherResults[loc.woeId])
                    }
                    strongSelf.delegate.onSuggestionStateChanged(state: enriched)
                }
            }
        })
        if let dispatchWorkItem = dispatchWorkItem {
            DispatchQueue.global().asyncAfter(deadline: .now() + DEFAULT_TIMEOUT_REQUEST, execute: dispatchWorkItem)
        }
    }

}