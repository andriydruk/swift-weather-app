//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private struct CachedWeather {
    let weather: Weather
    let timestamp: Date
}

class OpenWeatherProvider: WeatherProvider {

    private static let cacheTTL: TimeInterval = 300 // 5 minutes

    let sessionConfig = URLSessionConfiguration.default
    let session: URLSession
    private let apiKey: String

    var searchDataTask: URLSessionDataTask?

    private let cacheLock = NSLock()
    private var weatherCache = [String: CachedWeather]()

    init(apiKey: String) {
        self.session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        self.apiKey = apiKey
    }

    private func cacheKey(lat: Float, lon: Float) -> String {
        // Round to 2 decimal places (~1km precision) for cache key
        let rlat = (lat * 100).rounded() / 100
        let rlon = (lon * 100).rounded() / 100
        return "\(rlat),\(rlon)"
    }

    private func getCached(lat: Float, lon: Float) -> Weather? {
        let key = cacheKey(lat: lat, lon: lon)
        cacheLock.lock()
        defer { cacheLock.unlock() }
        guard let entry = weatherCache[key] else { return nil }
        if Date().timeIntervalSince(entry.timestamp) > OpenWeatherProvider.cacheTTL {
            weatherCache[key] = nil
            return nil
        }
        return entry.weather
    }

    private func putCache(lat: Float, lon: Float, weather: Weather) {
        let key = cacheKey(lat: lat, lon: lon)
        cacheLock.lock()
        weatherCache[key] = CachedWeather(weather: weather, timestamp: Date())
        cacheLock.unlock()
    }

    func searchLocations(query: String?, completionBlock: @escaping ([Location], Error?) -> ()) {
        searchDataTask?.cancel()
        guard let query = query, query.count > 0 else {
            completionBlock([], nil)
            return
        }
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://photon.komoot.io/api/?q=\(encodedQuery)&limit=20&osm_tag=place:city&lang=en") else {
            completionBlock([], nil)
            return
        }
        searchDataTask = session.dataTask(with: url) { [weak self] data, response, error in
            defer {
                self?.searchDataTask = nil
            }
            do {
                let result = try OpenWeatherProvider.parseResponse(PhotonResponse.self, data: data, response: response, error: error)
                let locations = (result?.features ?? []).compactMap { feature -> Location? in
                    guard let name = feature.properties.name else { return nil }
                    let coords = feature.geometry.coordinates
                    guard coords.count >= 2 else { return nil }
                    let lon = coords[0]
                    let lat = coords[1]
                    let code = feature.properties.countrycode ?? ""
                    let title = code.isEmpty ? name : "\(name), \(code)"
                    return Location(
                        woeId: Int64(abs("\(name)\(lat)\(lon)".hashValue)),
                        title: title,
                        latitude: lat,
                        longitude: lon
                    )
                }
                completionBlock(locations, nil)
            }
            catch {
                completionBlock([], error)
            }
        }
        searchDataTask?.resume()
    }

    func weather(location: Location, completionBlock: @escaping (Weather?, Error?) -> ()) {
        // Check cache first
        if let cached = getCached(lat: location.latitude, lon: location.longitude) {
            completionBlock(cached, nil)
            return
        }

        guard let currentUrl = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&units=metric&appid=\(apiKey)"),
              let forecastUrl = URL(string: "https://api.openweathermap.org/data/2.5/forecast?lat=\(location.latitude)&lon=\(location.longitude)&units=metric&appid=\(apiKey)") else {
            completionBlock(nil, nil)
            return
        }

        // Fetch current weather and forecast in parallel
        let group = DispatchGroup()
        var currentResult: OpenWeatherResponse?
        var forecastResult: OpenWeatherForecastResponse?
        var fetchError: Error?

        group.enter()
        let currentTask = session.dataTask(with: currentUrl) { data, response, error in
            defer { group.leave() }
            do {
                currentResult = try OpenWeatherProvider.parseResponse(OpenWeatherResponse.self, data: data, response: response, error: error)
            } catch {
                fetchError = error
            }
        }

        group.enter()
        let forecastTask = session.dataTask(with: forecastUrl) { data, response, error in
            defer { group.leave() }
            forecastResult = try? OpenWeatherProvider.parseResponse(OpenWeatherForecastResponse.self, data: data, response: response, error: error)
        }

        currentTask.resume()
        forecastTask.resume()

        group.notify(queue: .global()) { [weak self] in
            if let error = fetchError {
                completionBlock(nil, error)
                return
            }
            let hourly = forecastResult?.toHourlyForecasts() ?? []
            let daily = forecastResult?.toDailyForecasts() ?? []
            if let weather = currentResult?.toWeather(hourlyForecasts: hourly, dailyForecasts: daily) {
                self?.putCache(lat: location.latitude, lon: location.longitude, weather: weather)
                completionBlock(weather, nil)
            } else {
                completionBlock(nil, nil)
            }
        }
    }

    private static func parseResponse<T>(_ type: T.Type, data: Data?, response: URLResponse?, error: Error?) throws -> T? where T : Decodable {
        if let error = error {
            let urlError = error as NSError
            if urlError.domain == URLError.errorDomain, urlError.code == URLError.cancelled.rawValue {
                return nil // If task cancelled -> skip error
            }
            throw error
        } else if let data = data,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200 {
            do {
                return try JSONDecoder().decode(type, from: data)
            }
            catch let decodeError {
                throw decodeError
            }
        } else {
            return nil
        }
    }
}