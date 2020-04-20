//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation

// Fake DB with JSON persistence
// TODO: replace with SQLite
class JSONStorage: WeatherDatabase {

    private static let FILENAME = "db.json"

    private var locationsCache: [Location]?
    private var basePath: String

    init(basePath: String) {
        self.basePath = basePath
    }

    func loadLocations() -> [Location] {
        if locationsCache == nil {
            loadFromDisk()
        }
        return locationsCache ?? []
    }

    func addLocation(_ location: Location) {
        if locationsCache == nil {
            loadFromDisk()
        }
        let contains = locationsCache?.contains(where: { $0.woeId == location.woeId })
        if contains == false {
            locationsCache?.append(location)
            saveOnDisk()
        }
    }

    func removeLocation(_ location: Location) {
        if locationsCache == nil {
            loadFromDisk()
        }
        locationsCache?.removeAll(where: { $0.woeId == location.woeId })
        saveOnDisk()
    }

    private func loadFromDisk() {
        let fileURL = URL(fileURLWithPath: basePath).appendingPathComponent(JSONStorage.FILENAME)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                locationsCache = try JSONDecoder().decode([Location].self, from: data)
                return
            }
            catch {
                NSLog("loading error: \(error.localizedDescription)")
            }
        }

        // Default locations: Kiev, Berlin, San Fransisco
        locationsCache = [
            Location(woeId: 924938, title: "Kiev", latitude: 50.441380, longitude: 30.522490),
            Location(woeId: 638242, title: "Berlin", latitude: 52.516071, longitude: 13.376980),
            Location(woeId: 2487956, title: "San Francisco", latitude: 37.77712, longitude: -122.41964)
        ]
    }

    private func saveOnDisk() {
        let fileURL = URL(fileURLWithPath: basePath).appendingPathComponent(JSONStorage.FILENAME)
        let locations: [Location] = locationsCache ?? []
        do {
            let data = try JSONEncoder().encode(locations)
            try data.write(to: fileURL)
        }
        catch {
            NSLog("saving error: \(error) to file \(fileURL)")
        }
    }


}