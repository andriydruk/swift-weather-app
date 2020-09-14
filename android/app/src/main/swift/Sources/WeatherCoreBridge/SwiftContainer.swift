//
// Created by Andriy Druk on 13.09.2020.
//

import Foundation
import WeatherCore

public class SwiftContainer {

    private let container: WeatherCoreContainer

    public init(basePath: String) {
        self.container = WeatherCoreContainer(basePath: basePath)
    }

    public func getWeatherViewModel(delegate: LocationWeatherViewModelDelegate) -> LocationWeatherViewModel {
        return container.getWeatherViewModel(delegate: delegate)
    }

    public func getLocationSearchViewModel(delegate: LocationSearchDelegate) -> LocationSearchViewModel {
        return container.getLocationSearchViewModel(delegate: delegate)
    }

}