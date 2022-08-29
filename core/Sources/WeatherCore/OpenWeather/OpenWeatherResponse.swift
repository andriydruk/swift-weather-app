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
    let temp_min: Float
    let temp_max: Float
    let pressure: Int
    let humidity: Int
}

struct OpenWeatherWind: Codable {
    let speed: Float
    let deg: Int
}

extension OpenWeatherResponse {

    func toWeather() -> Weather {
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
                predictability: Float(visibility))
    }

    func toLocation() -> Location {
        Location(woeId: Int64(id), title: name, latitude: coord.lat, longitude: coord.lon)
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