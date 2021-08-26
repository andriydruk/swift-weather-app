package com.readdle.weather

import android.app.Application
import com.readdle.codegen.anotation.JavaSwift
import com.readdle.weather.core.SSLHelper
import com.readdle.weather.utils.copyAssetsIfNeeded
import dagger.hilt.android.HiltAndroidApp
import kotlin.concurrent.thread

@HiltAndroidApp
class WeatherApp: Application() {

    override fun onCreate() {
        super.onCreate()
        var sleep = true
        thread {
            //this gives Swift a mainThread of its own (for calling DispatchQueue.main.async etc)
            System.loadLibrary("WeatherCoreBridge")
            JavaSwift.init()
            assets.copyAssetsIfNeeded("cacert.pem", dataDir.absolutePath)
            SSLHelper.setupCert(dataDir.absolutePath)
            sleep = false
        }
        while (sleep) {
            Log.d("breezeApp", "sleeping")
        }
    }

}
