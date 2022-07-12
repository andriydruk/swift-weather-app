//
// Created by Andriy Druk on 01.09.2020.
//

import Foundation
import Dispatch

public protocol LocationSearchDelegate {
    func onSuggestionStateChanged(state: [Location])
    func onError(errorDescription: String)
}

private let DEFAULT_TIMEOUT_REQUEST = 0.1 // 100ms

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
        dispatchWorkItem = DispatchWorkItem(block: {
            self.provider.searchLocations(query: query) { [weak self] location, error in
                guard let strongSelf = self else {
                    return
                }
                if let error = error {
                    strongSelf.delegate.onError(errorDescription: error.localizedDescription)
                }
                else if let location = location {
                    strongSelf.delegate.onSuggestionStateChanged(state: [location])
                }
            }
        })
        if let dispatchWorkItem = dispatchWorkItem {
            DispatchQueue.global().asyncAfter(deadline: .now() + DEFAULT_TIMEOUT_REQUEST, execute: dispatchWorkItem)
        }
    }

}