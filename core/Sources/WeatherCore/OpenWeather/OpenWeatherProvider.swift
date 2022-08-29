//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class OpenWeatherProvider: WeatherProvider {

    let sessionConfig = URLSessionConfiguration.default
    let session: URLSession
    private let apiKey: String

    var searchDataTask: URLSessionDataTask?

    init(apiKey: String) {
        self.session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        self.apiKey = apiKey
    }

    func searchLocations(query: String?, completionBlock: @escaping (Location?, Error?) -> ()) {
        searchDataTask?.cancel()
        guard let query = query, query.count > 0 else {
            completionBlock(nil, nil)
            return
        }
        if var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather") {
            urlComponents.query = "q=\(query)&appid=\(apiKey)"
            guard let url = urlComponents.url else {
                return
            }
            searchDataTask = session.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.searchDataTask = nil
                }
                do {
                    let result = try OpenWeatherProvider.parseResponse(OpenWeatherResponse.self, data: data, response: response, error: error)
                    completionBlock(result?.toLocation(), nil)
                }
                catch {
                    completionBlock(nil, error)
                }
            }
            searchDataTask?.resume()
        }
    }

    func weather(location: Location, completionBlock: @escaping (Weather?, Error?) -> ()) {
        if let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&units=metric&appid=\(apiKey)") {
            let task = session.dataTask(with: url) { data, response, error in
                do {
                    let result = try OpenWeatherProvider.parseResponse(OpenWeatherResponse.self, data: data, response: response, error: error)
                    completionBlock(result?.toWeather() ?? nil, nil)
                }
                catch {
                    completionBlock(nil, error)
                }
            }
            task.resume()
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