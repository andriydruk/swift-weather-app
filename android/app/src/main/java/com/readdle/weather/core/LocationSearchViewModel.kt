package com.readdle.weather.core

import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference
import java.lang.annotation.Native

@SwiftReference
class LocationSearchViewModel private constructor() {

    // Swift JNI private native pointer
    @Native
    private val nativePointer = 0L

    // Swift JNI release method
    external fun release()

    @SwiftFunc("searchLocations(query:)")
	external fun searchLocations(query: String?)

}