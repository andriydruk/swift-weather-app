//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

public class WeatherCoreContainer {

	private let weatherProvider: WeatherProvider
	private let storage: WeatherDatabase

	public init(basePath: String) {
		weatherProvider = MetaWeatherProvider()
		storage = JSONStorage(basePath: basePath)
	}

	public func getWeatherViewModel(delegate: LocationWeatherViewModelDelegate) -> LocationWeatherViewModel {
		return LocationWeatherViewModel(db: storage, provider: weatherProvider, delegate: delegate)
	}

	public func getLocationSearchViewModel(delegate: LocationSearchDelegate) -> LocationSearchViewModel {
		return LocationSearchViewModel(provider: weatherProvider, delegate: delegate)
	}

}