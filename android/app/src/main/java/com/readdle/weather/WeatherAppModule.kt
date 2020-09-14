package com.readdle.weather

import android.app.Application
import com.readdle.weather.core.SwiftContainer
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
    fun weatherCoreContainer(application: Application): SwiftContainer {
        return SwiftContainer.init(application.dataDir.absolutePath)
    }
}