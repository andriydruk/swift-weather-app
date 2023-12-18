package com.readdle.weather.core;

import com.readdle.codegen.anotation.SwiftCallbackFunc
import com.readdle.codegen.anotation.SwiftDelegate

@SwiftDelegate(protocols = ["LocationWeatherViewModelDelegate"])
interface LocationWeatherViewModelDelegateAndroid {

    @SwiftCallbackFunc("onWeatherStateChanged(state:)")
	fun onWeatherStateChanged(state: ArrayList<LocationWeatherData>)

	@SwiftCallbackFunc("onError(errorDescription:)")
	fun onError(errorDescription: String)

    companion object {
        
    }

}