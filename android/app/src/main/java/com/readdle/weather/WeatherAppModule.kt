package com.readdle.weather

import android.app.Application
import com.readdle.weather.core.JSONStorage
import com.readdle.weather.core.MetaWeatherProvider
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import javax.inject.Singleton

@Module
@InstallIn(ApplicationComponent::class)
object WeatherAppModule {

    @Provides
    @Singleton
    fun metaWeatherProvider(): MetaWeatherProvider {
        return MetaWeatherProvider.init()
    }

    @Provides
    @Singleton
    fun jsonStorage(application: Application): JSONStorage {
        return JSONStorage.init(application.dataDir.absolutePath)
    }
}