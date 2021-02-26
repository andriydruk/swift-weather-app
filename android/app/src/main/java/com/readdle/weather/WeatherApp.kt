package com.readdle.weather

import android.app.Application
import com.readdle.codegen.anotation.JavaSwift
import com.readdle.weather.core.SSLHelper
import com.readdle.weather.utils.copyAssetsIfNeeded
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class WeatherApp: Application() {
    override fun onCreate() {
        super.onCreate()
        System.loadLibrary("WeatherCoreBridge")
        JavaSwift.init()
        assets.copyAssetsIfNeeded("cacert.pem", dataDir.absolutePath)
        SSLHelper.setupCert(dataDir.absolutePath)
    }
}