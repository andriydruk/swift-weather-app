//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

public struct Weather: Codable, Hashable {
    let state: WeatherState
    let date: Date
    let minTemp: Float
    let maxTemp: Float
    let temp: Float
    let windSpeed: Float
    let windDirection: Float
    let airPressure: Float
    let humidity: Float
    let visibility: Float
    let predictability: Float
}