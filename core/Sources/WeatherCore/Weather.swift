//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

public struct Weather: Codable, Hashable {
    public let state: WeatherState
    public let date: Date
    public let minTemp: Float
    public let maxTemp: Float
    public let temp: Float
    public let windSpeed: Float
    public let windDirection: Float
    public let airPressure: Float
    public let humidity: Float
    public let visibility: Float
    public let predictability: Float
}
