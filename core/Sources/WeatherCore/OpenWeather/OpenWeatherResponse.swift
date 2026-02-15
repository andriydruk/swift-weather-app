//
// Created by Maksym Sutkovenko on 11.07.2022.
//

import Foundation

// MARK: - Current Weather API response (/data/2.5/weather)

struct OpenWeatherResponse: Codable {
    let coord: OpenWeatherLocation
    let weather: [OpenWeatherCondition]
    let main: OpenWeatherMain
    let visibility: Int?
    let wind: OpenWeatherWind
    let id: Int
    let name: String
}

struct OpenWeatherLocation: Codable {
    let lon: Float
    let lat: Float
}

struct OpenWeatherMain: Codable {
    let temp: Float
    let feels_like: Float?
    let temp_min: Float
    let temp_max: Float
    let pressure: Int
    let humidity: Int
}

// MARK: - Weather condition
//
// Shared across current weather and forecast responses.
// The `id` field maps to weather condition groups:
//   2xx → thunderstorm
//   3xx → drizzle
//   5xx → rain
//   6xx → snow
//   7xx → atmosphere (mist, smoke, haze, dust, fog, sand, ash, squall, tornado)
//   800 → clear
//   80x → clouds
//
// Reference: https://openweathermap.org/weather-conditions

struct OpenWeatherCondition: Codable {
    let id: Int
    let main: String
}

// MARK: - Photon (Komoot) geocoding API response

struct PhotonResponse: Codable {
    let features: [PhotonFeature]
}

struct PhotonFeature: Codable {
    let geometry: PhotonGeometry
    let properties: PhotonProperties
}

struct PhotonGeometry: Codable {
    let coordinates: [Float] // [lon, lat]
}

struct PhotonProperties: Codable {
    let name: String?
    let country: String?
    let countrycode: String?
    let state: String?
    let city: String?
}

// MARK: - Forecast API response (/data/2.5/forecast)

struct OpenWeatherForecastResponse: Codable {
    let list: [OpenWeatherForecastItem]
}

struct OpenWeatherForecastItem: Codable {
    let dt: Int
    let main: OpenWeatherMain
    let weather: [OpenWeatherCondition]
    let wind: OpenWeatherWind
}

struct OpenWeatherWind: Codable {
    let speed: Float
    let deg: Int
}

// MARK: - Response → Model conversions

extension OpenWeatherResponse {

    func toWeather(hourlyForecasts: [HourlyForecast] = [], dailyForecasts: [DailyForecast] = []) -> Weather {
        Weather(state: weather.first?.toWeatherState() ?? .none,
                date: Date(),
                minTemp: main.temp_min,
                maxTemp: main.temp_max,
                temp: main.temp,
                windSpeed: wind.speed,
                windDirection: Float(wind.deg),
                airPressure: Float(main.pressure),
                humidity: Float(main.humidity),
                visibility: Float(visibility ?? 10000),
                predictability: Float(visibility ?? 10000),
                feelsLike: main.feels_like ?? main.temp,
                hourlyForecasts: hourlyForecasts,
                dailyForecasts: dailyForecasts)
    }

    func toLocation() -> Location {
        Location(woeId: Int64(id), title: name, latitude: coord.lat, longitude: coord.lon)
    }
}

extension OpenWeatherForecastResponse {

    func toHourlyForecasts() -> [HourlyForecast] {
        // Take first 8 items (24 hours at 3-hour intervals)
        return Array(list.prefix(8)).map { item in
            HourlyForecast(
                date: Date(timeIntervalSince1970: Double(item.dt)),
                temp: item.main.temp,
                state: item.weather.first?.toWeatherState() ?? .none
            )
        }
    }

    func toDailyForecasts() -> [DailyForecast] {
        // Group forecast items by day, compute min/max per day
        var dailyMap = [String: (minTemp: Float, maxTemp: Float, state: WeatherState, date: Date)]()
        var dayOrder = [String]()
        let calendar = Calendar.current

        for item in list {
            let date = Date(timeIntervalSince1970: Double(item.dt))
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let key = "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"

            if var existing = dailyMap[key] {
                existing.minTemp = min(existing.minTemp, item.main.temp_min)
                existing.maxTemp = max(existing.maxTemp, item.main.temp_max)
                dailyMap[key] = existing
            } else {
                dailyMap[key] = (
                    minTemp: item.main.temp_min,
                    maxTemp: item.main.temp_max,
                    state: item.weather.first?.toWeatherState() ?? .none,
                    date: date
                )
                dayOrder.append(key)
            }
        }

        return dayOrder.compactMap { key in
            guard let data = dailyMap[key] else { return nil }
            return DailyForecast(
                date: data.date,
                minTemp: data.minTemp,
                maxTemp: data.maxTemp,
                state: data.state
            )
        }
    }
}

// MARK: - Weather condition ID → WeatherState mapping
//
// Uses the numeric condition ID for robust mapping instead of string matching.
// The old string-based mapping missed Group 7xx conditions because the API
// returns specific `main` values ("Mist", "Smoke", "Haze", "Fog", etc.)
// rather than "Atmosphere".

extension OpenWeatherCondition {

    func toWeatherState() -> WeatherState {
        switch id {
        case 200..<300: return .thunderstorm
        case 300..<400: return .drizzle
        case 500..<600: return .rain
        case 600..<700: return .snow
        case 700..<800: return .atmosphere
        case 800:       return .clear
        case 801..<900: return .clouds
        default:        return .none
        }
    }
}