//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

public protocol WeatherDatabase {

    func loadLocations() -> [Location]

    func addLocation(_ location: Location)

    func removeLocation(_ location: Location)

    func clearDB()

}