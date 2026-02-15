import XCTest
@testable import WeatherCore

class LocationSearchViewModelTest: XCTestCase {

    func testSearchLocationsSuccessful() {
        let suggestionExpectation = expectation(description: "onSearchSuggestionChanged should be called")
        suggestionExpectation.expectedFulfillmentCount = 2 // initial + enriched with weather
        let repository = createViewModel(suggestionExpectation: suggestionExpectation)
        repository.searchLocations(query: "test")
        wait(for: [suggestionExpectation], timeout: 2.0)
    }

    func testSearchLocationsFail() {
        let errorExpectation = expectation(description: "onError should be called")
        let repository = createViewModel(errorExpectation: errorExpectation)
        repository.searchLocations(query: "error")
        wait(for: [errorExpectation], timeout: 2.0)
    }

    func createViewModel(suggestionExpectation: XCTestExpectation? = nil,
                         errorExpectation: XCTestExpectation? = nil) -> LocationSearchViewModel {
        let fakeProvider = FakeProvider()
        let fakeDelegate = FakeWeatherRepositoryDelegate(suggestionExpectation: suggestionExpectation, errorExpectation: errorExpectation)
        return LocationSearchViewModel(provider: fakeProvider, delegate: fakeDelegate)
    }

    struct FakeProvider: WeatherProvider {

        func searchLocations(query: String?, completionBlock: @escaping ([Location], Error?) -> ()) {
            if query == "error" {
                completionBlock([], NSError(domain: "", code: 0))
            }
            else {
                completionBlock([fakeLocation], nil)
            }
        }

        func weather(location: Location, completionBlock: @escaping (Weather?, Error?) -> ()) {
            if location.woeId == 0 {
                completionBlock(fakeWeather, nil)
            }
            else {
                completionBlock(nil, NSError(domain: "", code: 0))
            }
        }
    }
    
    struct FakeWeatherRepositoryDelegate: LocationSearchDelegate {
    
        let suggestionExpectation: XCTestExpectation?
        let errorExpectation: XCTestExpectation?
        
        func onSuggestionStateChanged(state: [LocationWeatherData]) {
            if let first = state.first {
                XCTAssertEqual(first.location.woeId, fakeLocation.woeId)
            }
            suggestionExpectation?.fulfill()
        }
        
        func onError(errorDescription: String) {
            XCTAssert(errorDescription.contains("error 0"))
            errorExpectation?.fulfill()
        }
    }

}
