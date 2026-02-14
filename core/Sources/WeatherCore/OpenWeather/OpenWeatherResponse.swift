//
// Created by Maksym Sutkovenko on 11.07.2022.
//

import Foundation

struct OpenWeatherResponse: Codable {
    let coord: OpenWeatherLocation
    let weather: [OpenWeather]
    let main: OpenWeatherMain
    let visibility: Int
    let wind: OpenWeatherWind
    let id: Int
    let name: String
}

struct OpenWeatherLocation: Codable {
    let lon: Float
    let lat: Float
}

struct OpenWeather: Codable {
    let id: Int
    let main: String
}

struct OpenWeatherMain: Codable {
    let temp: Float
    let feels_like: Float?
    let temp_min: Float
    let temp_max: Float
    let pressure: Int
    let humidity: Int
}

// MARK: - Geocoding API response

struct GeocodingResult: Codable {
    let name: String
    let lat: Float
    let lon: Float
    let country: String
    let state: String?
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

// MARK: - Forecast API response

struct OpenWeatherForecastResponse: Codable {
    let list: [OpenWeatherForecastItem]
}

struct OpenWeatherForecastItem: Codable {
    let dt: Int
    let main: OpenWeatherMain
    let weather: [OpenWeather]
    let wind: OpenWeatherWind
}

struct OpenWeatherWind: Codable {
    let speed: Float
    let deg: Int
}

extension OpenWeatherResponse {

    func toWeather(hourlyForecasts: [HourlyForecast] = [], dailyForecasts: [DailyForecast] = []) -> Weather {
        Weather(state: weather.first?.main.toWeatherState() ?? .none,
                date: Date(),
                minTemp: main.temp_min,
                maxTemp: main.temp_max,
                temp: main.temp,
                windSpeed: wind.speed,
                windDirection: Float(wind.deg),
                airPressure: Float(main.pressure),
                humidity: Float(main.humidity),
                visibility: Float(visibility),
                predictability: Float(visibility),
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
                state: item.weather.first?.main.toWeatherState() ?? .none
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
                    state: item.weather.first?.main.toWeatherState() ?? .none,
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

fileprivate extension String {

    func toWeatherState() -> WeatherState {
        switch self {
        case "Thunderstorm": return .thunderstorm
        case "Drizzle": return .drizzle
        case "Rain": return .rain
        case "Snow": return .snow
        case "Atmosphere": return .atmosphere
        case "Clear":  return .clear
        case "Clouds": return .clouds
        default: return .none
        }
    }
}