import XCTest
@testable import WeatherCore

let fakeLocation = Location(woeId: 0, title: "Fake", latitude: 0.0, longitude: 0.0)
let fakeWeather = Weather(state: .clear, date: Date(), minTemp: 0.0, maxTemp: 0.0,
        temp: 0.0, windSpeed: 0.0, windDirection: 0.0, airPressure: 0.0,
        humidity: 0.0, visibility: 0.0, predictability: 0.0)

class WeatherRepositoryTest: XCTestCase {

    func testLoadSavedLocations() {
        let locationExpectation = expectation(description: "onSavedLocationChanged should be called")
        let weatherExpectation = expectation(description: "onWeatherChanged should be called")
        let repository = createRepository(locationExpectation: locationExpectation, weatherExpectation: weatherExpectation)
        repository.loadSavedLocations()
        wait(for: [locationExpectation, weatherExpectation], timeout: 1.0)
    }

    func testAddLocationToSaved() {
        let addExpectation = expectation(description: "addLocation should be called")
        let locationExpectation = expectation(description: "onSavedLocationChanged should be called")
        let weatherExpectation = expectation(description: "onWeatherChanged should be called")
        let repository = createRepository(addExpectation: addExpectation, locationExpectation: locationExpectation, weatherExpectation: weatherExpectation)
        repository.addLocationToSaved(location: fakeLocation)
        wait(for: [addExpectation, locationExpectation, weatherExpectation], timeout: 1.0)
    }

    func testRemoveSavedLocation() {
        let removeExpectation = expectation(description: "removeLocation should be called")
        let locationExpectation = expectation(description: "onSavedLocationChanged should be called")
        let repository = createRepository(removeExpectation: removeExpectation, locationExpectation: locationExpectation)
        repository.removeSavedLocation(location: fakeLocation)
        wait(for: [removeExpectation, locationExpectation], timeout: 1.0)
    }

    func testSearchLocationsSuccessful() {
        let suggestionExpectation = expectation(description: "onSearchSuggestionChanged should be called")
        let repository = createRepository(suggestionExpectation: suggestionExpectation)
        repository.searchLocations(query: "")
        wait(for: [suggestionExpectation], timeout: 1.0)
    }

    func testSearchLocationsFail() {
        let errorExpectation = expectation(description: "onError should be called")
        let repository = createRepository(errorExpectation: errorExpectation)
        repository.searchLocations(query: nil)
        wait(for: [errorExpectation], timeout: 1.0)
    }

    func testWeatherSuccessful() {
        let weatherExpectation = expectation(description: "onWeatherChanged should be called")
        let repository = createRepository(weatherExpectation: weatherExpectation)
        repository.weather(withWoeId: 0)
        wait(for: [weatherExpectation], timeout: 1.0)
    }

    func testWeatherFail() {
        let errorExpectation = expectation(description: "onError should be called")
        let repository = createRepository(errorExpectation: errorExpectation)
        repository.weather(withWoeId: 1)
        wait(for: [errorExpectation], timeout: 1.0)
    }

    func createRepository(addExpectation: XCTestExpectation? = nil,
                          removeExpectation: XCTestExpectation? = nil,
                          locationExpectation: XCTestExpectation? = nil,
                          weatherExpectation: XCTestExpectation? = nil,
                          suggestionExpectation: XCTestExpectation? = nil,
                          errorExpectation: XCTestExpectation? = nil) -> WeatherRepository {
        let fakeDatabase = FakeDatabase(addExpectation: addExpectation, removeExpectation: removeExpectation)
        let fakeProvider = FakeProvider()
        let fakeDelegate = FakeWeatherRepositoryDelegate(locationExpectation: locationExpectation,
                weatherExpectation: weatherExpectation,
                suggestionExpectation: suggestionExpectation,
                errorExpectation: errorExpectation)
        return WeatherRepository(db: fakeDatabase, provider: fakeProvider, delegate: fakeDelegate)
    }

    struct FakeDatabase: WeatherDatabase {

        let addExpectation: XCTestExpectation?
        let removeExpectation: XCTestExpectation?

        func loadLocations() -> [Location] {
            return [fakeLocation]
        }

        func addLocation(_ location: Location) {
            XCTAssertEqual(location, fakeLocation)
            addExpectation?.fulfill()
        }

        func removeLocation(_ location: Location) {
            XCTAssertEqual(location, fakeLocation)
            removeExpectation?.fulfill()
        }

        func clearDB() { }

    }

    struct FakeProvider: WeatherProvider {

        func searchLocations(query: String?, completionBlock: @escaping ([Location]?, Error?) -> Void) {
            if query != nil {
                completionBlock([fakeLocation], nil)
            }
            else {
                completionBlock(nil, NSError(domain: "", code: 0))
            }
        }

        func weather(withWoeId woeId: UInt64, completionBlock: @escaping ([Weather]?, Error?) -> Void) {
            if woeId == 0 {
                completionBlock([fakeWeather], nil)
            }
            else {
                completionBlock(nil, NSError(domain: "", code: 0))
            }
        }

    }
    struct FakeWeatherRepositoryDelegate: WeatherRepositoryDelegate {

        let locationExpectation: XCTestExpectation?
        let weatherExpectation: XCTestExpectation?
        let suggestionExpectation: XCTestExpectation?
        let errorExpectation: XCTestExpectation?

        func onSavedLocationChanged(locations: [Location]) {
            XCTAssertEqual(locations.first, fakeLocation)
            locationExpectation?.fulfill()
        }

        func onWeatherChanged(woeId: Int64, weather: Weather) {
            XCTAssertEqual(woeId, fakeLocation.woeId)
            XCTAssertEqual(weather, fakeWeather)
            weatherExpectation?.fulfill()
        }

        func onSearchSuggestionChanged(locations: [Location]) {
            XCTAssertEqual(locations.first, fakeLocation)
            suggestionExpectation?.fulfill()
        }

        func onError(errorDescription: String) {
            XCTAssertEqual(errorDescription, "The operation could not be completed. ( error 0.)")
            errorExpectation?.fulfill()
        }
    }

}