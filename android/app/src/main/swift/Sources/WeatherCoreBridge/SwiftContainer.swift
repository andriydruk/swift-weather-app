//
// Created by Andriy Druk on 13.09.2020.
//

import Foundation
import WeatherCore
import Swinject

public class SwiftContainer {

    private let container: Container

    public init(basePath: String) {
        self.container = WeatherCoreContainer.createContainer(basePath: basePath)
    }

    public func getWeatherViewModel(delegate: LocationWeatherViewModelDelegate) -> LocationWeatherViewModel {
        return container.resolve(LocationWeatherViewModel.self, argument: delegate)!
    }

    public func getLocationSearchViewModel(delegate: LocationSearchDelegate) -> LocationSearchViewModel {
        return container.resolve(LocationSearchViewModel.self, argument: delegate)!
    }

}
