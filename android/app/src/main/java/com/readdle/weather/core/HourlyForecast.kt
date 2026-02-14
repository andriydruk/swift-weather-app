package com.readdle.weather.core

import android.os.Parcelable
import com.readdle.codegen.anotation.SwiftValue
import kotlinx.parcelize.Parcelize
import java.util.Date

@SwiftValue @Parcelize
data class HourlyForecast(
    var date: Date = Date(),
    var temp: Float = 0.0f,
    var state: WeatherState = WeatherState.NONE
): Parcelable
