package com.readdle.weather.ui.screens

import androidx.compose.animation.AnimatedVisibilityScope
import androidx.compose.animation.ExperimentalSharedTransitionApi
import androidx.compose.animation.SharedTransitionScope
import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.readdle.weather.core.Location
import com.readdle.weather.core.LocationWeatherData
import com.readdle.weather.core.WeatherState
import com.readdle.weather.ui.cityBoundsKey
import com.readdle.weather.ui.theme.*
import kotlin.math.roundToInt

@OptIn(ExperimentalSharedTransitionApi::class, ExperimentalMaterial3Api::class)
@Composable
fun CityListScreen(
    locations: List<LocationWeatherData>,
    currentPageIndex: Int,
    onCityClick: (Int) -> Unit,
    onAddClick: () -> Unit,
    onRemoveCity: (Location) -> Unit,
    sharedTransitionScope: SharedTransitionScope,
    animatedVisibilityScope: AnimatedVisibilityScope,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(WeatherBlue)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
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
                Text(
                    text = "Weather",
                    color = TextWhite,
                    fontSize = 34.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = (-0.5).sp
                )

                IconButton(onClick = onAddClick) {
                    Icon(
                        Icons.Default.Add,
                        contentDescription = "Add City",
                        tint = TextWhite
                    )
                }
            }

            // City List
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
                contentPadding = PaddingValues(vertical = 8.dp)
            ) {
                items(
                    count = locations.size,
                    key = { locations[it].location.woeId }
                ) { index ->
                    val data = locations[index]
                    val dismissState = rememberSwipeToDismissBoxState(
                        confirmValueChange = { value ->
                            if (value == SwipeToDismissBoxValue.EndToStart) {
                                onRemoveCity(data.location)
                            }
                            false // Never confirm - let list recomposition remove the item
                        }
                    )

                    with(sharedTransitionScope) {
                        SwipeToDismissBox(
                            state = dismissState,
                            modifier = Modifier
                                .animateItem()
                                .sharedBounds(
                                    sharedContentState = rememberSharedContentState(
                                        key = cityBoundsKey(index)
                                    ),
                                    animatedVisibilityScope = animatedVisibilityScope,
                                    resizeMode = SharedTransitionScope.ResizeMode.ScaleToBounds()
                                )
                                .clip(RoundedCornerShape(12.dp)),
                            enableDismissFromStartToEnd = false,
                            enableDismissFromEndToStart = true,
                            backgroundContent = {
                                val color by animateColorAsState(
                                    targetValue = when (dismissState.targetValue) {
                                        SwipeToDismissBoxValue.EndToStart -> Color(0xFFE53935)
                                        else -> Color.Transparent
                                    },
                                    label = "swipe_bg"
                                )
                                Box(
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .background(color, RoundedCornerShape(12.dp))
                                        .padding(horizontal = 24.dp),
                                    contentAlignment = Alignment.CenterEnd
                                ) {
                                    Icon(
                                        Icons.Default.Delete,
                                        contentDescription = "Delete",
                                        tint = TextWhite,
                                        modifier = Modifier.size(28.dp)
                                    )
                                }
                            }
                        ) {
                            CityRow(
                                data = data,
                                onClick = { onCityClick(index) }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun CityRow(
    data: LocationWeatherData,
    onClick: () -> Unit
) {
    val weather = data.weather
    val location = data.location

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(0xFF5A9BE8), RoundedCornerShape(12.dp))
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column(
            verticalArrangement = Arrangement.spacedBy(4.dp),
            modifier = Modifier.weight(1f)
        ) {
            Text(
                text = location.title.substringBefore(","),
                color = TextWhite,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                maxLines = 1,
                overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis
            )
            Text(
                text = getWeatherDescription(weather?.state),
                color = TextWhite70,
                fontSize = 15.sp,
                fontWeight = FontWeight.Medium
            )
        }

        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.End,
            modifier = Modifier.width(170.dp)
        ) {
            Icon(
                imageVector = getWeatherIcon(weather?.state),
                contentDescription = null,
                modifier = Modifier.size(36.dp),
                tint = getWeatherIconTint(weather?.state)
            )
            if (weather != null) {
                Text(
                    text = "${weather.minTemp.roundToInt()}°",
                    color = TextWhite70,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Normal,
                    modifier = Modifier.width(52.dp),
                    textAlign = TextAlign.End
                )
                Text(
                    text = "${weather.maxTemp.roundToInt()}°",
                    color = TextWhite,
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.width(52.dp),
                    textAlign = TextAlign.End
                )
            } else {
                Spacer(modifier = Modifier.width(60.dp))
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = TextWhite70,
                    strokeWidth = 2.dp
                )
            }
        }
    }
}
