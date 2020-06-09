package com.readdle.weather.core

import com.readdle.codegen.anotation.SwiftValue

@SwiftValue
data class Location(
    val woeId: Long = 0,
    val title: String = "",
    val latitude: Float = 0.0f,
    val longitude: Float = 0.0f
)