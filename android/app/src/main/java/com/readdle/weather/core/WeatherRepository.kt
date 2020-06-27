package com.readdle.weather.core

import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference

@SwiftReference
class WeatherRepository private constructor() {

    // Swift JNI private native pointer
    private val nativePointer = 0L

    // Swift JNI release method
    external fun release()

    external fun loadSavedLocations()

    @SwiftFunc("addLocationToSaved(location:)")
    external fun addLocationToSaved(location: Location)

    @SwiftFunc("removeSavedLocation(location:)")
    external fun removeSavedLocation(location: Location)

    @SwiftFunc("searchLocations(query:)")
    external fun searchLocations(query: String?)

    companion object {

        @JvmStatic
        @SwiftFunc("init(db:provider:delegate:)")
        external fun init(db: JSONStorage,
                          provider: MetaWeatherProvider,
                          delegate: WeatherRepositoryDelegateAndroid): WeatherRepository
    }

}