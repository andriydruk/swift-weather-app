import XCTest
@testable import WeatherCore

#if os(Android)
let temporaryDirectory = "/data/local/tmp"
#else
let temporaryDirectory = NSTemporaryDirectory()
#endif

class WeatherDatabaseTest: XCTestCase {

    private var database: WeatherDatabase!

    override func setUp() {
        super.setUp()
        database = JSONStorage(basePath: temporaryDirectory)
        database.clearDB()
    }

    func testDefaults() {
        let defaultLocations = database.loadLocations()
        XCTAssert(defaultLocations.count == 5)
    }

    func testAddLocation() {
        database.addLocation(Location(woeId: 0, title: "Fake", latitude: 0.0, longitude: 0.0))
        let locations = database.loadLocations()
        XCTAssert(locations.count == 6)
        XCTAssertNotNil(locations.first(where: { $0.woeId == 0}))
    }

    func testRemoveLocation() {
        guard let firstLocation = database.loadLocations().first else {
            XCTFail()
            return
        }
        database.removeLocation(firstLocation)
        XCTAssert(database.loadLocations().count == 4)
    }

    func testClearLocation() {
        database.addLocation(Location(woeId: 0, title: "Fake", latitude: 0.0, longitude: 0.0))
        database.clearDB()
        let locations = database.loadLocations()
        XCTAssert(locations.count == 5)
        XCTAssertNil(locations.first(where: { $0.woeId == 0}))
    }
}
