//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

public enum WeatherState: Int, Codable {
    case none
    case snow
    case thunderstorm
    case clear
    case drizzle
    case rain
    case clouds
    case atmosphere
}