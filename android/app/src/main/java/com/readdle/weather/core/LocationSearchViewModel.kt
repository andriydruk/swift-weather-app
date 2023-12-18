package com.readdle.weather.core;

import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference

@SwiftReference
class LocationSearchViewModel private constructor() {

    // Swift JNI private native pointer
    private val nativePointer = 0L

    // Swift JNI release method
    external fun release()

    @SwiftFunc("searchLocations(query:)")
	external fun searchLocations(query: String?)

    companion object {
        
    }

}