package com.readdle.weather.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.readdle.weather.core.LocationWeatherData
import com.readdle.weather.core.WeatherState
import com.readdle.weather.ui.theme.*
import kotlin.math.roundToInt

@Composable
fun WeatherDetailScreen(
    weatherData: LocationWeatherData,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val weather = weatherData.weather
    val location = weatherData.location

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(WeatherGreen)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .verticalScroll(rememberScrollState())
        ) {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp)
                    .padding(horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                IconButton(onClick = onBack) {
                    Icon(
                        Icons.Default.ArrowBack,
                        contentDescription = "Back",
                        tint = TextWhite
                    )
                }

                Text(
                    text = "7-Day Forecast",
                    color = TextWhite,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Medium
                )

                IconButton(onClick = { }) {
                    Icon(
                        Icons.Default.MoreVert,
                        contentDescription = "More",
                        tint = TextWhite
                    )
                }
            }

            // Forecast list
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Today
                ForecastDayRow(
                    dayName = "Today",
                    condition = getWeatherDescription(weather?.state),
                    weatherState = weather?.state,
                    lowTemp = weather?.minTemp?.roundToInt()?.toString() ?: "--",
                    highTemp = weather?.maxTemp?.roundToInt()?.toString() ?: "--"
                )

                // Generate sample days
                val days = listOf("Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "Monday")
                val conditions = listOf(
                    WeatherState.CLOUDS, WeatherState.CLEAR, WeatherState.RAIN,
                    WeatherState.CLEAR, WeatherState.CLOUDS, WeatherState.CLEAR, WeatherState.DRIZZLE
                )

                days.forEachIndexed { index, day ->
                    val state = conditions[index % conditions.size]
                    val baseTempLow = (weather?.minTemp ?: 15f) + (-3..3).random()
                    val baseTempHigh = (weather?.maxTemp ?: 25f) + (-3..3).random()
                    ForecastDayRow(
                        dayName = day,
                        condition = getWeatherDescription(state),
                        weatherState = state,
                        lowTemp = "${baseTempLow.roundToInt()}",
                        highTemp = "${baseTempHigh.roundToInt()}"
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
        }
    }
}

@Composable
private fun ForecastDayRow(
    dayName: String,
    condition: String,
    weatherState: WeatherState?,
    lowTemp: String,
    highTemp: String
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(72.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(CardOverlay)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        // Day and condition
        Column(
            verticalArrangement = Arrangement.spacedBy(4.dp),
            modifier = Modifier.weight(1f)
        ) {
            Text(
                text = dayName,
                color = TextWhite,
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium
            )
            Text(
                text = condition,
                color = TextWhite70,
                fontSize = 13.sp,
                fontWeight = FontWeight.Normal
            )
        }

        // Weather icon
        Icon(
            imageVector = getWeatherIcon(weatherState),
            contentDescription = null,
            modifier = Modifier.size(32.dp),
            tint = if (weatherState == WeatherState.CLEAR) WeatherYellow
                   else Color(0xFFE0E0E0)
        )

        Spacer(modifier = Modifier.width(16.dp))

        // Temps
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "$lowTemp°",
                color = TextWhite70,
                fontSize = 16.sp,
                fontWeight = FontWeight.Normal
            )
            Text(
                text = "$highTemp°",
                color = TextWhite,
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium
            )
        }
    }
}
