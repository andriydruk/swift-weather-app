package com.readdle.weather.core

import android.os.Parcelable
import com.readdle.codegen.anotation.SwiftValue
import kotlinx.parcelize.Parcelize

@SwiftValue @Parcelize
enum class WeatherState(val rawValue: Int): Parcelable {

	NONE(0),
	SNOW(1),
	THUNDERSTORM(2),
	CLEAR(3),
	DRIZZLE(4),
	RAIN(5),
	CLOUDS(6),
	ATMOSPHERE(7);

    companion object {

        private val values = HashMap<Int, WeatherState>()

        @JvmStatic
        fun valueOf(rawValue: Int): WeatherState {
            return values[rawValue]!!
        }

        init {
            enumValues<WeatherState>().forEach {
                values[it.rawValue] = it
            }
        }
    }

}