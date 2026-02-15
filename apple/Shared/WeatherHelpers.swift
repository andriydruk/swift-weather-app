//
//  WeatherHelpers.swift
//  Shared
//

import SwiftUI
import WeatherCore

// MARK: - Colors

extension Color {
    static let weatherBlue = Color(red: 0.29, green: 0.565, blue: 0.886)   // #4A90E2
    static let weatherCardBlue = Color(red: 0.353, green: 0.608, blue: 0.91) // #5A9BE8
    static let cardOverlay = Color.white.opacity(0.1)
    static let textWhite = Color.white
    static let textWhite70 = Color.white.opacity(0.7)
    static let textWhite50 = Color.white.opacity(0.5)
}

// MARK: - Weather Icon Mapping (SF Symbols)

func weatherIconName(_ state: WeatherState?) -> String {
    guard let state = state else { return "cloud.fill" }
    switch state {
    case .clear:        return "sun.max.fill"
    case .clouds:       return "cloud.fill"
    case .rain:         return "cloud.rain.fill"
    case .drizzle:      return "cloud.drizzle.fill"
    case .snow:         return "cloud.snow.fill"
    case .thunderstorm: return "cloud.bolt.rain.fill"
    case .atmosphere:   return "cloud.fog.fill"
    case .none:         return "sun.max.fill"
    }
}

func weatherIconColor(_ state: WeatherState?) -> Color {
    guard let state = state else { return .white }
    switch state {
    case .clear:        return .yellow
    case .clouds:       return .white
    case .rain:         return Color(red: 0.6, green: 0.8, blue: 1.0)
    case .drizzle:      return Color(red: 0.7, green: 0.85, blue: 1.0)
    case .snow:         return Color(red: 0.85, green: 0.92, blue: 1.0)
    case .thunderstorm: return Color(red: 1.0, green: 0.85, blue: 0.3)
    case .atmosphere:   return Color(red: 0.8, green: 0.8, blue: 0.8)
    case .none:         return .yellow
    }
}

// MARK: - Weather Descriptions

func weatherDescription(_ state: WeatherState?) -> String {
    guard let state = state else { return "Loading..." }
    switch state {
    case .clear:        return "Clear"
    case .clouds:       return "Cloudy"
    case .rain:         return "Rainy"
    case .drizzle:      return "Light Rain"
    case .snow:         return "Snow"
    case .thunderstorm: return "Thunderstorm"
    case .atmosphere:   return "Hazy"
    case .none:         return "Clear"
    }
}

// MARK: - Wind Direction

func windDirection(_ degrees: Float) -> String {
    let dirs = ["North", "NE", "East", "SE", "South", "SW", "West", "NW"]
    let index = Int((degrees + 22.5) / 45.0) % 8
    return dirs[index]
}

// MARK: - Date Formatters

let hourlyFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "ha"
    f.locale = Locale(identifier: "en_US")
    return f
}()

let dayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "EEEE"
    f.locale = Locale(identifier: "en_US")
    return f
}()

// MARK: - Humidity Description

func humidityDescription(_ humidity: Float) -> String {
    humidity > 70 ? "High" : "Comfortable"
}
