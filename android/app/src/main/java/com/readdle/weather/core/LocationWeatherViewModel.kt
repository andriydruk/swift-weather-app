// Generated using JavaSwift codegen by Sourcery
// DO NOT EDIT

package com.readdle.weather.core;

import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference

@SwiftReference
class LocationWeatherViewModel private constructor() {

    // Swift JNI private native pointer
    private val nativePointer = 0L

    // Swift JNI release method
    external fun release()

    @SwiftFunc("addLocationToSaved(location:)")
	external fun addLocationToSaved(location: Location)

	@SwiftFunc("removeSavedLocation(location:)")
	external fun removeSavedLocation(location: Location)

    companion object {
        
    }

}