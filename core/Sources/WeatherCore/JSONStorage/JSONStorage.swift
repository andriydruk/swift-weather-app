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

    public init(basePath: String) {
        self.basePath = basePath
    }

    public func loadLocations() -> [Location] {
        if locationsCache == nil {
            loadFromDisk()
        }
        return locationsCache ?? []
    }

    public func addLocation(_ location: Location) {
        if locationsCache == nil {
            loadFromDisk()
        }
        // Check by woeId or by proximity (within ~10km)
        let isDuplicate = locationsCache?.contains(where: {
            $0.woeId == location.woeId ||
            (abs($0.latitude - location.latitude) < 0.1 && abs($0.longitude - location.longitude) < 0.1)
        }) ?? false
        if !isDuplicate {
            locationsCache?.append(location)
            saveOnDisk()
        }
    }

    public func findExistingLocation(_ location: Location) -> Location? {
        if locationsCache == nil {
            loadFromDisk()
        }
        return locationsCache?.first(where: {
            $0.woeId == location.woeId ||
            (abs($0.latitude - location.latitude) < 0.1 && abs($0.longitude - location.longitude) < 0.1)
        })
    }

    public func removeLocation(_ location: Location) {
        NSLog("removeLocation: \(location)")
        if locationsCache == nil {
            NSLog("loadFromDisk")
            loadFromDisk()
        }
        NSLog("locationsCache: \(locationsCache)")
        locationsCache?.removeAll(where: { $0.woeId == location.woeId })
        NSLog("locationsCache after remove: \(locationsCache)")
        saveOnDisk()
    }

    public func clearDB() {
        let fileURL = URL(fileURLWithPath: basePath).appendingPathComponent(JSONStorage.FILENAME)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                locationsCache = nil
            }
            catch {
                NSLog("Can't remove file \(fileURL), error: \(error.localizedDescription)")
            }
        }
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

        // Default locations - Readdle office cities
        locationsCache = [
            Location(woeId: 929717, title: "Odesa, UA", latitude: 46.482952, longitude: 30.712481),
            Location(woeId: 924938, title: "Kyiv, UA", latitude: 50.450100, longitude: 30.523400),
            Location(woeId: 638242, title: "Berlin, DE", latitude: 52.520008, longitude: 13.404954),
            Location(woeId: 44418, title: "London, GB", latitude: 51.507351, longitude: -0.127758),
            Location(woeId: 523920, title: "Warsaw, PL", latitude: 52.229676, longitude: 21.012229)
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
