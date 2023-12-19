package com.readdle.weather.core;

import android.os.Parcelable
import com.readdle.codegen.anotation.SwiftValue
import kotlinx.parcelize.Parcelize

@SwiftValue @Parcelize
data class Location(
        var woeId: Long = 0,
		var title: String = "",
		var latitude: Float = 0.0f,
		var longitude: Float = 0.0f
): Parcelable