// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import XCTest
@testable import WeatherCoreTests



extension WeatherDatabaseTest {
  static var allTests = [
	  ("testDefaults", testDefaults),
  	  ("testAddLocation", testAddLocation),
  	  ("testRemoveLocation", testRemoveLocation),
  	  ("testClearLocation", testClearLocation),
	]

}

extension WeatherRepositoryTest {
  static var allTests = [
	  ("testLoadSavedLocations", testLoadSavedLocations),
  	  ("testAddLocationToSaved", testAddLocationToSaved),
  	  ("testRemoveSavedLocation", testRemoveSavedLocation),
  	  ("testSearchLocationsSuccessful", testSearchLocationsSuccessful),
  	  ("testSearchLocationsFail", testSearchLocationsFail),
  	  ("testWeatherSuccessful", testWeatherSuccessful),
  	  ("testWeatherFail", testWeatherFail),
	]

}


XCTMain([
		testCase(WeatherDatabaseTest.allTests),
		testCase(WeatherRepositoryTest.allTests),
])
