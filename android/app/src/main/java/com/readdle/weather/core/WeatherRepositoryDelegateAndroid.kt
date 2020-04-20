package com.readdle.weather.core

import com.readdle.codegen.anotation.SwiftCallbackFunc
import com.readdle.codegen.anotation.SwiftDelegate
import com.readdle.codegen.anotation.Unsigned

@SwiftDelegate(protocols = ["WeatherRepositoryDelegate"])
interface WeatherRepositoryDelegateAndroid {

    @SwiftCallbackFunc("onSearchSuggestionChanged(locations:)")
    fun onSearchSuggestionChanged(locations: ArrayList<Location>)

    @SwiftCallbackFunc("onSavedLocationChanged(locations:)")
    fun onSavedLocationChanged(locations: ArrayList<Location>)

    @SwiftCallbackFunc("onError(errorDescription:)")
    fun onError(errorDescription: String)

    @SwiftCallbackFunc("onWeatherChanged(woeId:weather:)")
    fun onWeatherChanged(woeId: Long, weather: Weather)

}