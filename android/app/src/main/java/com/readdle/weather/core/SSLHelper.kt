package com.readdle.weather.core

import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference
import java.lang.annotation.Native

@SwiftReference
class SSLHelper private constructor() {

    // Swift JNI private native pointer
    private val nativePointer = 0L

    // Swift JNI release method
    external fun release()

    companion object {
        @JvmStatic @SwiftFunc("setupCert(basePath:)")
		external fun setupCert(basePath: String)
    }

}