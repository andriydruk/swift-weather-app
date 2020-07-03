package com.readdle.weather.core

import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference

@SwiftReference
class JSONStorage private constructor() {

    // Swift JNI private native pointer
    private val nativePointer = 0L

    // Swift JNI release method
    external fun release()

    companion object {

        @JvmStatic
        @SwiftFunc("init(basePath:)")
        external fun init(basePath: String): JSONStorage
    }
}