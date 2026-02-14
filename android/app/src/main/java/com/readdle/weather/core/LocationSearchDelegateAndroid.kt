package com.readdle.weather.core;

import com.readdle.codegen.anotation.SwiftCallbackFunc
import com.readdle.codegen.anotation.SwiftDelegate

@SwiftDelegate(protocols = ["LocationSearchDelegate"])
interface LocationSearchDelegateAndroid {

    @SwiftCallbackFunc("onSuggestionStateChanged(state:)")
	fun onSuggestionStateChanged(state: ArrayList<LocationWeatherData>)

	@SwiftCallbackFunc("onError(errorDescription:)")
	fun onError(errorDescription: String)

    companion object {
        
    }

}