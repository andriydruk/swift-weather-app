package com.readdle.weather.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

val WeatherBlue = Color(0xFF4A90E2)
val WeatherGreen = Color(0xFF2E7D32)
val WeatherPurple = Color(0xFF5749F4)
val WeatherYellow = Color(0xFFFFE57F)

val CardOverlay = Color(0x1AFFFFFF)
val TextWhite = Color(0xFFFFFFFF)
val TextWhite70 = Color(0xB3FFFFFF)
val TextWhite50 = Color(0x80FFFFFF)

private val LightColorScheme = lightColorScheme(
    primary = WeatherPurple,
    onPrimary = Color.White,
    secondary = Color(0xFFD9D9DB),
    onSecondary = Color(0xFF2A2933),
    background = Color.White,
    onBackground = Color(0xFF2A2933),
    surface = Color.White,
    onSurface = Color(0xFF2A2933),
    surfaceVariant = Color(0xFFF5F5F5),
    onSurfaceVariant = Color(0xFF616167),
    outline = Color(0xFFC5C5CB),
)

@Composable
fun WeatherAppTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        content = content
    )
}
