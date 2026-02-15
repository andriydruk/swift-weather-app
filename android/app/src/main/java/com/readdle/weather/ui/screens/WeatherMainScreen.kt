package com.readdle.weather.ui.screens

import androidx.compose.animation.AnimatedVisibilityScope
import androidx.compose.animation.ExperimentalSharedTransitionApi
import androidx.compose.animation.SharedTransitionScope
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.awaitEachGesture
import androidx.compose.foundation.gestures.awaitFirstDown
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.annotation.DrawableRes
import androidx.compose.foundation.Image
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.rounded.Air
import androidx.compose.material.icons.rounded.Cloud
import androidx.compose.material.icons.rounded.Compress
import androidx.compose.material.icons.rounded.WaterDrop
import androidx.compose.material.icons.rounded.WbSunny
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.readdle.weather.R
import com.readdle.weather.core.LocationWeatherData
import com.readdle.weather.core.WeatherState
import com.readdle.weather.ui.cityBoundsKey
import com.readdle.weather.ui.theme.*
import java.text.SimpleDateFormat
import java.util.Locale
import kotlin.math.roundToInt

@OptIn(ExperimentalSharedTransitionApi::class)
@Composable
fun WeatherMainScreen(
    allLocations: List<LocationWeatherData>,
    initialPage: Int,
    onPageChanged: (Int) -> Unit,
    onMenuClick: () -> Unit,
    onSearchClick: () -> Unit,
    sharedTransitionScope: SharedTransitionScope,
    animatedVisibilityScope: AnimatedVisibilityScope,
    modifier: Modifier = Modifier
) {
    if (allLocations.isEmpty()) {
        Box(
            modifier = modifier.fillMaxSize().background(WeatherBlue),
            contentAlignment = Alignment.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Icon(Icons.Rounded.Cloud, null, Modifier.size(80.dp), tint = TextWhite70)
                Text("No cities added", color = TextWhite, fontSize = 20.sp, fontWeight = FontWeight.Medium)
                Text("Tap search to add a city", color = TextWhite70, fontSize = 14.sp)
            }
        }
        return
    }

    val pagerState = rememberPagerState(
        initialPage = initialPage.coerceIn(0, (allLocations.size - 1).coerceAtLeast(0)),
        pageCount = { allLocations.size }
    )

    LaunchedEffect(pagerState) {
        snapshotFlow { pagerState.settledPage }.collect { onPageChanged(it) }
    }

    val settledPage = pagerState.settledPage

    with(sharedTransitionScope) {
        Box(
            modifier = modifier
                .fillMaxSize()
                .sharedBounds(
                    sharedContentState = rememberSharedContentState(key = cityBoundsKey(settledPage)),
                    animatedVisibilityScope = animatedVisibilityScope,
                    resizeMode = SharedTransitionScope.ResizeMode.ScaleToBounds()
                )
                .background(WeatherBlue)
                .statusBarsPadding()
        ) {
            // Pager - disabled when user is scrolling hourly forecast
            val pagerScrollEnabled = remember { mutableStateOf(true) }
            Box(modifier = Modifier.fillMaxSize()) {
                HorizontalPager(
                    state = pagerState,
                    modifier = Modifier.fillMaxSize(),
                    userScrollEnabled = pagerScrollEnabled.value
                ) { page ->
                    WeatherPageContent(
                        data = allLocations[page],
                        pagerScrollEnabled = pagerScrollEnabled
                    )
                }
                if (allLocations.size > 1) {
                    Row(
                        modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 16.dp).navigationBarsPadding(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        repeat(allLocations.size) { i ->
                            Box(
                                Modifier
                                    .size(if (i == pagerState.currentPage) 8.dp else 6.dp)
                                    .clip(CircleShape)
                                    .background(if (i == pagerState.currentPage) TextWhite else TextWhite50)
                            )
                        }
                    }
                }
            }

            // Overlay buttons - hamburger and search on top
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 4.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                IconButton(onClick = onMenuClick) {
                    Icon(Icons.Default.Menu, "Menu", tint = TextWhite)
                }
                IconButton(onClick = onSearchClick) {
                    Icon(Icons.Default.Search, "Search", tint = TextWhite)
                }
            }
        }
    }
}

@Composable
private fun WeatherPageContent(
    data: LocationWeatherData,
    pagerScrollEnabled: MutableState<Boolean>
) {
    val weather = data.weather
    val hourlyFormat = SimpleDateFormat("ha", Locale.US)
    val dayFormat = SimpleDateFormat("EEEE", Locale.US)

    Column(
        modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState())
    ) {
        // Hero section
        Column(
            modifier = Modifier.fillMaxWidth().padding(top = 48.dp, bottom = 20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Text(
                text = data.location.title.substringBefore(","),
                color = TextWhite,
                fontSize = 36.sp,
                fontWeight = FontWeight.Medium,
                maxLines = 1,
                overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis,
                modifier = Modifier.padding(horizontal = 16.dp)
            )

            // Icon + Temperature on one row
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Image(
                    painter = painterResource(getWeatherIcon(weather?.state)),
                    contentDescription = null,
                    modifier = Modifier.size(80.dp)
                )
                Text(
                    text = if (weather != null) "${weather.temp.roundToInt()}\u00B0" else "--\u00B0",
                    color = TextWhite,
                    fontSize = 96.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = (-4).sp
                )
            }

            Text(
                text = if (weather != null) "Feels like ${weather.feelsLike.roundToInt()}\u00B0" else "",
                color = TextWhite70,
                fontSize = 18.sp,
                fontWeight = FontWeight.Normal
            )
        }

        // Hourly Forecast - horizontal scroll (disables pager while touching)
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(CardOverlay)
                .pointerInput(Unit) {
                    awaitEachGesture {
                        awaitFirstDown(requireUnconsumed = false)
                        pagerScrollEnabled.value = false
                        do {
                            val event = awaitPointerEvent()
                        } while (event.changes.any { it.pressed })
                        pagerScrollEnabled.value = true
                    }
                }
                .padding(12.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = "Hourly Forecast",
                color = TextWhite70,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                letterSpacing = 0.5.sp
            )
            HorizontalDivider(color = TextWhite50.copy(alpha = 0.3f), thickness = 0.5.dp)

            if (weather != null && weather.hourlyForecasts.isNotEmpty()) {
                val hourlyListState = rememberLazyListState()
                LazyRow(
                    state = hourlyListState,
                    horizontalArrangement = Arrangement.spacedBy(20.dp),
                    userScrollEnabled = true
                ) {
                    items(weather.hourlyForecasts) { forecast ->
                        HourlyItem(
                            time = hourlyFormat.format(forecast.date),
                            temp = "${forecast.temp.roundToInt()}\u00B0",
                            weatherState = forecast.state
                        )
                    }
                }
            } else {
                // Placeholder when no forecast data
                val placeholderListState = rememberLazyListState()
                LazyRow(
                    state = placeholderListState,
                    horizontalArrangement = Arrangement.spacedBy(20.dp),
                    userScrollEnabled = true
                ) {
                    val hours = listOf("Now", "3PM", "6PM", "9PM", "12AM", "3AM")
                    items(hours) { hour ->
                        HourlyItem(
                            time = hour,
                            temp = if (weather != null) "${(weather.temp + (-3..3).random()).roundToInt()}\u00B0" else "--\u00B0",
                            weatherState = weather?.state
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Daily Forecast list
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(CardOverlay)
                .padding(12.dp),
            verticalArrangement = Arrangement.spacedBy(0.dp)
        ) {
            Text(
                text = "5-Day Forecast",
                color = TextWhite70,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                letterSpacing = 0.5.sp
            )
            HorizontalDivider(
                color = TextWhite50.copy(alpha = 0.3f),
                thickness = 0.5.dp,
                modifier = Modifier.padding(vertical = 8.dp)
            )

            if (weather != null && weather.dailyForecasts.isNotEmpty()) {
                weather.dailyForecasts.forEachIndexed { index, forecast ->
                    DailyForecastRow(
                        dayName = if (index == 0) "Today" else dayFormat.format(forecast.date),
                        state = forecast.state,
                        low = "${forecast.minTemp.roundToInt()}\u00B0",
                        high = "${forecast.maxTemp.roundToInt()}\u00B0"
                    )
                    if (index < weather.dailyForecasts.size - 1) {
                        HorizontalDivider(
                            color = TextWhite50.copy(alpha = 0.2f),
                            thickness = 0.5.dp,
                            modifier = Modifier.padding(vertical = 4.dp)
                        )
                    }
                }
            } else {
                // Placeholder
                val days = listOf("Today", "Tuesday", "Wednesday", "Thursday", "Friday")
                days.forEachIndexed { index, day ->
                    DailyForecastRow(
                        dayName = day,
                        state = weather?.state,
                        low = if (weather != null) "${(weather.minTemp + (-3..0).random()).roundToInt()}\u00B0" else "--\u00B0",
                        high = if (weather != null) "${(weather.maxTemp + (0..3).random()).roundToInt()}\u00B0" else "--\u00B0"
                    )
                    if (index < days.size - 1) {
                        HorizontalDivider(
                            color = TextWhite50.copy(alpha = 0.2f),
                            thickness = 0.5.dp,
                            modifier = Modifier.padding(vertical = 4.dp)
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Detail Cards Grid
        Column(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Row(Modifier.fillMaxWidth().height(IntrinsicSize.Max), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                DetailCard("FEELS LIKE", Icons.Rounded.WbSunny,
                    if (weather != null) "${weather.feelsLike.roundToInt()}" else "--",
                    "\u00B0", "", Modifier.weight(1f).fillMaxHeight())
                DetailCard("HUMIDITY", Icons.Rounded.WaterDrop,
                    if (weather != null) "${weather.humidity.roundToInt()}" else "--",
                    "%", if (weather != null && weather.humidity > 70) "High" else "Comfortable", Modifier.weight(1f).fillMaxHeight())
            }
            Row(Modifier.fillMaxWidth().height(IntrinsicSize.Max), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                DetailCard("WIND", Icons.Rounded.Air,
                    if (weather != null) "${weather.windSpeed.roundToInt()}" else "--",
                    " mph", getWindDirection(weather?.windDirection ?: 0f), Modifier.weight(1f).fillMaxHeight())
                DetailCard("PRESSURE", Icons.Rounded.Compress,
                    if (weather != null) "${weather.airPressure.roundToInt()}" else "--",
                    "", "hPa", Modifier.weight(1f).fillMaxHeight())
            }
        }

        Spacer(modifier = Modifier.height(60.dp).navigationBarsPadding())
    }
}

@Composable
private fun HourlyItem(time: String, temp: String, weatherState: WeatherState?) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(time, color = TextWhite70, fontSize = 15.sp, fontWeight = FontWeight.Medium)
        Image(
            painter = painterResource(getWeatherIcon(weatherState)),
            contentDescription = null,
            modifier = Modifier.size(28.dp)
        )
        Text(temp, color = TextWhite, fontSize = 18.sp, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
private fun DailyForecastRow(dayName: String, state: WeatherState?, low: String, high: String) {
    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = dayName,
            color = TextWhite,
            fontSize = 18.sp,
            fontWeight = FontWeight.Medium,
            modifier = Modifier.weight(1f)
        )
        Image(
            painter = painterResource(getWeatherIcon(state)),
            contentDescription = null,
            modifier = Modifier.size(28.dp)
        )
        Spacer(Modifier.width(20.dp))
        Text(low, color = TextWhite50, fontSize = 18.sp, fontWeight = FontWeight.Normal,
            modifier = Modifier.width(42.dp))
        Spacer(Modifier.width(8.dp))
        Text(high, color = TextWhite, fontSize = 18.sp, fontWeight = FontWeight.SemiBold,
            modifier = Modifier.width(42.dp))
    }
}

@Composable
private fun DetailCard(title: String, icon: ImageVector, value: String, unit: String, description: String, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier.clip(RoundedCornerShape(12.dp)).background(CardOverlay).padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
            Icon(icon, null, Modifier.size(16.dp), tint = TextWhite70)
            Text(title, color = TextWhite70, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, letterSpacing = 0.5.sp)
        }
        Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(2.dp)) {
            Text(value, color = TextWhite, fontSize = 32.sp, fontWeight = FontWeight.Bold)
            if (unit.isNotEmpty()) {
                Text(unit, color = TextWhite70, fontSize = 18.sp, modifier = Modifier.padding(bottom = 4.dp))
            }
        }
        if (description.isNotEmpty()) {
            Text(description, color = TextWhite70, fontSize = 14.sp, fontWeight = FontWeight.Medium)
        }
    }
}

@DrawableRes
fun getWeatherIcon(state: WeatherState?): Int = when (state) {
    WeatherState.CLEAR -> R.drawable.weather_condition_clear_day
    WeatherState.CLOUDS -> R.drawable.weather_condition_cloudy
    WeatherState.RAIN -> R.drawable.weather_condition_rain
    WeatherState.DRIZZLE -> R.drawable.weather_condition_drizzle
    WeatherState.SNOW -> R.drawable.weather_condition_snow
    WeatherState.THUNDERSTORM -> R.drawable.weather_condition_thunderstorms
    WeatherState.ATMOSPHERE -> R.drawable.weather_condition_fog
    WeatherState.NONE -> R.drawable.weather_condition_clear_day
    null -> R.drawable.weather_condition_cloudy
}

fun getWeatherDescription(state: WeatherState?): String = when (state) {
    WeatherState.CLEAR -> "Clear"
    WeatherState.CLOUDS -> "Cloudy"
    WeatherState.RAIN -> "Rainy"
    WeatherState.DRIZZLE -> "Light Rain"
    WeatherState.SNOW -> "Snow"
    WeatherState.THUNDERSTORM -> "Thunderstorm"
    WeatherState.ATMOSPHERE -> "Hazy"
    WeatherState.NONE -> "Clear"
    null -> "Loading..."
}

fun getWindDirection(degrees: Float): String {
    val dirs = listOf("North", "NE", "East", "SE", "South", "SW", "West", "NW")
    return dirs[((degrees + 22.5f) / 45f).toInt() % 8]
}
