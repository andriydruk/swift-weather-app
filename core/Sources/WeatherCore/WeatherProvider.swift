//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

protocol WeatherProvider {

    func searchLocations(query: String?, completionBlock: @escaping (Location?, Error?) -> ())

    func weather(location: Location, completionBlock: @escaping (Weather?, Error?) -> ())
}