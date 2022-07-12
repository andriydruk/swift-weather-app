import XCTest
@testable import WeatherCore

class LocationSearchViewModelTest: XCTestCase {

    func testSearchLocationsSuccessful() {
        let suggestionExpectation = expectation(description: "onSearchSuggestionChanged should be called")
        let repository = createViewModel(suggestionExpectation: suggestionExpectation)
        repository.searchLocations(query: "")
        wait(for: [suggestionExpectation], timeout: 1.0)
    }

    func testSearchLocationsFail() {
        let errorExpectation = expectation(description: "onError should be called")
        let repository = createViewModel(errorExpectation: errorExpectation)
        repository.searchLocations(query: nil)
        wait(for: [errorExpectation], timeout: 1.0)
    }

    func createViewModel(suggestionExpectation: XCTestExpectation? = nil,
                         errorExpectation: XCTestExpectation? = nil) -> LocationSearchViewModel {
        let fakeProvider = FakeProvider()
        let fakeDelegate = FakeWeatherRepositoryDelegate(suggestionExpectation: suggestionExpectation, errorExpectation: errorExpectation)
        return LocationSearchViewModel(provider: fakeProvider, delegate: fakeDelegate)
    }

    struct FakeProvider: WeatherProvider {

        func searchLocations(query: String?, completionBlock: @escaping (Location?, Error?) -> ()) {
            if query != nil {
                completionBlock(fakeLocation, nil)
            }
            else {
                completionBlock(nil, NSError(domain: "", code: 0))
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
        
        func onSuggestionStateChanged(state: [Location]) {
            XCTAssertEqual(state.first?.woeId, fakeLocation.woeId)
            suggestionExpectation?.fulfill()
        }
        
        func onError(errorDescription: String) {
            #if os(Android)
            XCTAssertEqual(errorDescription, "The operation could not be completed. ( error 0.)")
            #else
            XCTAssertEqual(errorDescription, "The operation couldn’t be completed. ( error 0.)")
            #endif
            errorExpectation?.fulfill()
        }
    }

}
