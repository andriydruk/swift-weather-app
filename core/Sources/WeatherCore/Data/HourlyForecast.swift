//
// HourlyForecast.swift
//

import Foundation

public struct HourlyForecast: Codable, Hashable {
    public let date: Date
    public let temp: Float
    public let state: WeatherState

    public init(date: Date, temp: Float, state: WeatherState) {
        self.date = date
        self.temp = temp
        self.state = state
    }
}
