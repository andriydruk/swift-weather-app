//
// DailyForecast.swift
//

import Foundation

public struct DailyForecast: Codable, Hashable {
    public let date: Date
    public let minTemp: Float
    public let maxTemp: Float
    public let state: WeatherState

    public init(date: Date, minTemp: Float, maxTemp: Float, state: WeatherState) {
        self.date = date
        self.minTemp = minTemp
        self.maxTemp = maxTemp
        self.state = state
    }
}
