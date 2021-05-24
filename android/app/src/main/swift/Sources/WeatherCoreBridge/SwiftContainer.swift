//
// Created by Andriy Druk on 13.09.2020.
//

import Foundation
import WeatherCore
import Cleanse

public class SwiftContainer {

    private let factory: WeatherCoreFactory

    public init(basePath: String) {
        self.factory = try! ComponentFactory.of(WeatherCoreComponent.prepare(withBasePath: basePath)).build(())
    }

    public func getWeatherViewModel(delegate: LocationWeatherViewModelDelegate) -> LocationWeatherViewModel {
        return factory.weatherViewModelFactory.build(delegate)
    }

    public func getLocationSearchViewModel(delegate: LocationSearchDelegate) -> LocationSearchViewModel {
        return factory.searchViewModelFactory.build(delegate)
    }

}
