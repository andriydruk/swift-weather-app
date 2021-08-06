//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class MetaWeatherProvider: WeatherProvider {

    let sessionConfig = URLSessionConfiguration.default
    let session: URLSession

    var searchDataTask: URLSessionDataTask?

    init() {
        self.session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    }

    func searchLocations(query: String?, completionBlock: @escaping ([Location]?, Error?) -> Void) {
        searchDataTask?.cancel()
        guard let query = query, query.count > 0 else {
            completionBlock([], nil)
            return
        }
        if var urlComponents = URLComponents(string: "https://www.metaweather.com/api/location/search/") {
            urlComponents.query = "query=\(query)"
            guard let url = urlComponents.url else {
                return
            }
            searchDataTask = session.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.searchDataTask = nil
                }
                do {
                    let result = try MetaWeatherProvider.parseResponse([MetaWeatherLocation].self, data: data, response: response, error: error)
                    completionBlock(result?.map({ $0.toLocation() }), nil)
                }
                catch {
                    completionBlock(nil, error)
                }
            }
            searchDataTask?.resume()
        }
    }

    func weather(withWoeId woeId: UInt64, completionBlock: @escaping ([Weather]?, Error?) -> Void) {
        if let url = URL(string: "https://www.metaweather.com/api/location/\(woeId)") {
            let task = session.dataTask(with: url) { data, response, error in
                do {
                    let result = try MetaWeatherProvider.parseResponse(MetaWeatherResponse.self, data: data, response: response, error: error)
                    completionBlock(result?.consolidated_weather.map({ $0.toWeather() }), nil)
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