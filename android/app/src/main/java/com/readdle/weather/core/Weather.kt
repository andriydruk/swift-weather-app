package com.readdle.weather.core;

import android.os.Parcelable
import com.readdle.codegen.anotation.SwiftValue
import kotlinx.parcelize.Parcelize
import java.util.Date

@SwiftValue @Parcelize
data class Weather(
        var state: WeatherState = WeatherState.NONE,
		var date: Date = Date(),
		var minTemp: Float = 0.0f,
		var maxTemp: Float = 0.0f,
		var temp: Float = 0.0f,
		var windSpeed: Float = 0.0f,
		var windDirection: Float = 0.0f,
		var airPressure: Float = 0.0f,
		var humidity: Float = 0.0f,
		var visibility: Float = 0.0f,
		var predictability: Float = 0.0f,
		var feelsLike: Float = 0.0f,
		var hourlyForecasts: ArrayList<HourlyForecast> = arrayListOf(),
		var dailyForecasts: ArrayList<DailyForecast> = arrayListOf()
): Parcelable