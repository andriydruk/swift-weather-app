// Generated using JavaSwift codegen by Sourcery
// DO NOT EDIT

package com.readdle.weather.core;

import android.os.Parcelable
import com.readdle.codegen.anotation.SwiftValue
import kotlinx.android.parcel.Parcelize

@SwiftValue @Parcelize
data class LocationWeatherData(
        var location: Location = Location(),
		var weather: Weather? = null
): Parcelable