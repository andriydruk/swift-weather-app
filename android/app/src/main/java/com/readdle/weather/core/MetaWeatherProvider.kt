package com.readdle.weather.core

import com.readdle.codegen.anotation.SwiftReference

@SwiftReference
class MetaWeatherProvider private constructor() {

    // Swift JNI private native pointer
    private val nativePointer = 0L

    // Swift JNI release method
    external fun release()

    companion object {

        @JvmStatic
        external fun init(): MetaWeatherProvider
    }
}