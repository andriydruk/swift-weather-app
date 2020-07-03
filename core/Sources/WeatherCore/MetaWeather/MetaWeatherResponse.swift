//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

struct MetaWeatherResponse: Codable {
    let woeid: Int64
    let title: String
    let timezone_name: String
    let timezone: String
    let consolidated_weather: [MetaWeatherInfo]
}

struct MetaWeatherInfo: Codable {
    let id: UInt64
    let weather_state_name: String
    let weather_state_abbr: String
    let wind_direction_compass: String
    let created: String
    let applicable_date: String
    let min_temp: Float
    let max_temp: Float
    let the_temp: Float
    let wind_speed: Float
    let wind_direction: Float
    let air_pressure: Float
    let humidity: Float
    let visibility: Float
    let predictability: Float
}

extension MetaWeatherInfo {

    func toWeather() -> Weather {

        var weatherState = WeatherState.none
        switch weather_state_abbr {
        case "sn": weatherState = .snow
        case "sl": weatherState = .sleet
        case "h": weatherState = .hail
        case "t": weatherState = .thunderstorm
        case "hr": weatherState = .heavyRain
        case "lr": weatherState = .lightRain
        case "s": weatherState = .showers
        case "hc": weatherState = .heavyCloud
        case "lc": weatherState = .lightCloud
        case "c": weatherState = .clear
        default: weatherState = .none
        }

        return Weather(state: weatherState,
                date: Date(),
                minTemp: min_temp,
                maxTemp: max_temp,
                temp: the_temp,
                windSpeed: wind_speed,
                windDirection: wind_direction,
                airPressure: air_pressure,
                humidity: humidity,
                visibility: visibility,
                predictability: predictability / 100)
    }
}

struct MetaWeatherLocation: Codable {

    let woeid: Int64
    let title: String
    let location_type: String
    let latt_long: String

}

extension MetaWeatherLocation {

    func toLocation() -> Location {
        let coordinate = latt_long.split(separator: ",")
        if coordinate.count == 2,
           let latitude = Float(coordinate[0].trimmingCharacters(in: .whitespaces)),
           let longitude = Float(coordinate[1].trimmingCharacters(in: .whitespaces))  {
            return Location(woeId: woeid, title: title, latitude: latitude, longitude: longitude)
        }
        NSLog("coordinate: \(coordinate) could not be converted")
        return Location(woeId: woeid, title: title, latitude: .nan, longitude: .nan)
    }

}