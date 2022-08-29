// Generated using JavaSwift codegen by Sourcery
// DO NOT EDIT

package com.readdle.weather.core;

import com.readdle.codegen.anotation.SwiftValue

@SwiftValue
enum class WeatherState(val rawValue: Int) {

	NONE(0), 
	SNOW(1),
	THUNDERSTORM(2),
	SHOWERS(3),
	CLEAR(4),
    DRIZZLE(5),
    RAIN(6),
    CLOUDS(7),
    ATMOSPHERE(8);

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