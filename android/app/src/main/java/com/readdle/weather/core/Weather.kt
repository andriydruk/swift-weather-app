package com.readdle.weather.core

import com.readdle.codegen.anotation.SwiftValue
import java.util.*

@SwiftValue
data class Weather(
    val state: WeatherState = WeatherState.NONE,
    val date: Date = Date(),
    val minTemp: Float = Float.NaN,
    val maxTemp: Float = Float.NaN,
    val temp: Float = Float.NaN,
    val windSpeed: Float = Float.NaN,
    val windDirection: Float = Float.NaN,
    val airPressure: Float = Float.NaN,
    val humidity: Float = Float.NaN,
    val visibility: Float = Float.NaN,
    val predictability: Float = Float.NaN
)