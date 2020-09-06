// Generated using JavaSwift codegen by Sourcery
// DO NOT EDIT

package com.readdle.weather.core;

import com.readdle.codegen.anotation.SwiftValue

@SwiftValue
enum class WeatherState(val rawValue: Int) {

	NONE(0), 
	SNOW(1), 
	SLEET(2), 
	HAIL(3), 
	THUNDERSTORM(4), 
	HEAVY_RAIN(5), 
	LIGHT_RAIN(6), 
	SHOWERS(7), 
	HEAVY_CLOUD(8), 
	LIGHT_CLOUD(9), 
	CLEAR(10);

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