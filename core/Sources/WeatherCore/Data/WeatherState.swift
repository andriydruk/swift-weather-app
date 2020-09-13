//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

public enum WeatherState: Int, Codable {
    case none
    case snow
    case sleet
    case hail
    case thunderstorm
    case heavyRain
    case lightRain
    case showers
    case heavyCloud
    case lightCloud
    case clear
}