package com.readdle.weather

import android.app.Application
import com.readdle.weather.core.SwiftContainer
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object WeatherAppModule {

    @Provides
    @Singleton
    fun weatherCoreContainer(application: Application): SwiftContainer {
        return SwiftContainer.init(application.dataDir.absolutePath, BuildConfig.API_KEY)
    }
}