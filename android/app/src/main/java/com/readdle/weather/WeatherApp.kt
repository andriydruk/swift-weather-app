package com.readdle.weather

import android.app.Application
import com.readdle.codegen.anotation.JavaSwift
import com.readdle.weather.utils.copyAssetsIfNeeded

class WeatherApp: Application() {

    override fun onCreate() {
        super.onCreate()
        System.loadLibrary("WeatherCore")
        JavaSwift.init()
        assets.copyAssetsIfNeeded("cacert.pem", dataDir.absolutePath)
    }

}