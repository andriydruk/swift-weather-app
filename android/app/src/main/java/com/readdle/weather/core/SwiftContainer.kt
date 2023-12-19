package com.readdle.weather.core;

import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference

@SwiftReference
class SwiftContainer private constructor() {

    // Swift JNI private native pointer
    private val nativePointer = 0L

    // Swift JNI release method
    external fun release()

    @SwiftFunc("getWeatherViewModel(delegate:)")
	external fun getWeatherViewModel(delegate: LocationWeatherViewModelDelegateAndroid): LocationWeatherViewModel

	@SwiftFunc("getLocationSearchViewModel(delegate:)")
	external fun getLocationSearchViewModel(delegate: LocationSearchDelegateAndroid): LocationSearchViewModel

    companion object {
        @JvmStatic @SwiftFunc("init(basePath:apiKey:)")
		external fun init(basePath: String, apiKey: String): SwiftContainer
    }

}