package com.readdle.weather.core

import android.os.Parcelable
import com.readdle.codegen.anotation.SwiftValue
import kotlinx.parcelize.Parcelize
import java.util.Date

@SwiftValue @Parcelize
data class DailyForecast(
    var date: Date = Date(),
    var minTemp: Float = 0.0f,
    var maxTemp: Float = 0.0f,
    var state: WeatherState = WeatherState.NONE
): Parcelable
