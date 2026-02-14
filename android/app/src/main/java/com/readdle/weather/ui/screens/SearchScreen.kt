package com.readdle.weather.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.rounded.AddCircleOutline
import androidx.compose.material.icons.rounded.LocationOn
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.readdle.weather.core.Location
import com.readdle.weather.core.LocationWeatherData
import com.readdle.weather.ui.theme.*
import kotlin.math.roundToInt

@Composable
fun SearchScreen(
    suggestions: List<LocationWeatherData>,
    savedLocations: List<LocationWeatherData>,
    onQueryChange: (String) -> Unit,
    onLocationAdd: (Location) -> Unit,
    onLocationClick: (LocationWeatherData) -> Unit,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    var query by remember { mutableStateOf("") }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(WeatherBlue)
            .statusBarsPadding()
    ) {
        // Header with search bar
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Title row
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "Search",
                    color = TextWhite,
                    fontSize = 34.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = (-0.5).sp
                )
                TextButton(onClick = onBack) {
                    Text(
                        text = "Cancel",
                        color = TextWhite70,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Medium
                    )
                }
            }

            // Search input
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(CardOverlay)
                    .padding(horizontal = 14.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Icon(
                    Icons.Default.Search,
                    contentDescription = null,
                    tint = TextWhite50,
                    modifier = Modifier.size(22.dp)
                )

                BasicTextField(
                    value = query,
                    onValueChange = {
                        query = it
                        onQueryChange(it)
                    },
                    modifier = Modifier.weight(1f),
                    textStyle = TextStyle(
                        fontSize = 17.sp,
                        color = TextWhite,
                        fontWeight = FontWeight.Normal
                    ),
                    singleLine = true,
                    cursorBrush = SolidColor(TextWhite),
                    decorationBox = { innerTextField ->
                        Box {
                            if (query.isEmpty()) {
                                Text(
                                    text = "Enter city name...",
                                    color = TextWhite50,
                                    fontSize = 17.sp
                                )
                            }
                            innerTextField()
                        }
                    }
                )

                if (query.isNotEmpty()) {
                    IconButton(
                        onClick = {
                            query = ""
                            onQueryChange("")
                        },
                        modifier = Modifier.size(28.dp)
                    ) {
                        Icon(
                            Icons.Default.Close,
                            contentDescription = "Clear",
                            tint = TextWhite50,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }
            }
        }

        // Results
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(0.dp)
        ) {
            // Search suggestions when typing
            if (query.isNotEmpty()) {
                if (suggestions.isNotEmpty()) {
                    item {
                        Text(
                            text = "Results",
                            color = TextWhite70,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.SemiBold,
                            letterSpacing = 0.5.sp,
                            modifier = Modifier.padding(vertical = 12.dp)
                        )
                    }
                    items(suggestions) { data ->
                        SuggestionRow(
                            data = data,
                            onClick = {
                                onLocationAdd(data.location)
                                query = ""
                                onQueryChange("")
                            }
                        )
                    }
                } else if (query.length < 2) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 32.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "Type city name to search",
                                color = TextWhite50,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }
                } else {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 32.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "No cities found",
                                color = TextWhite50,
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }
                }
            }

            // Saved locations when no query
            if (query.isEmpty() && savedLocations.isNotEmpty()) {
                item {
                    Text(
                        text = "Saved Cities",
                        color = TextWhite70,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.SemiBold,
                        letterSpacing = 0.5.sp,
                        modifier = Modifier.padding(vertical = 12.dp)
                    )
                }
                items(savedLocations) { data ->
                    SavedCityRow(
                        data = data,
                        onClick = { onLocationClick(data) }
                    )
                }
            }
        }
    }
}

@Composable
private fun SuggestionRow(
    data: LocationWeatherData,
    onClick: () -> Unit
) {
    val weather = data.weather

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 2.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(CardOverlay)
            .clickable(onClick = onClick)
            .padding(horizontal = 14.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.weight(1f)
        ) {
            if (weather != null) {
                Icon(
                    getWeatherIcon(weather.state),
                    contentDescription = null,
                    modifier = Modifier.size(28.dp),
                    tint = getWeatherIconTint(weather.state)
                )
            } else {
                Icon(
                    Icons.Rounded.LocationOn,
                    contentDescription = null,
                    modifier = Modifier.size(28.dp),
                    tint = TextWhite70
                )
            }
            Text(
                text = data.location.title,
                fontSize = 17.sp,
                fontWeight = FontWeight.Medium,
                color = TextWhite
            )
        }
        if (weather != null) {
            Text(
                text = "${weather.temp.roundToInt()}\u00B0",
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = TextWhite
            )
        } else {
            Icon(
                Icons.Rounded.AddCircleOutline,
                contentDescription = "Add",
                modifier = Modifier.size(24.dp),
                tint = TextWhite70
            )
        }
    }
}

@Composable
private fun SavedCityRow(
    data: LocationWeatherData,
    onClick: () -> Unit
) {
    val weather = data.weather

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 2.dp)
            .clip(RoundedCornerShape(12.dp))
            .background(CardOverlay)
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.weight(1f)
        ) {
            Icon(
                getWeatherIcon(weather?.state),
                contentDescription = null,
                modifier = Modifier.size(28.dp),
                tint = getWeatherIconTint(weather?.state)
            )
            Text(
                text = data.location.title,
                fontSize = 18.sp,
                fontWeight = FontWeight.Medium,
                color = TextWhite
            )
        }
        if (weather != null) {
            Text(
                text = "${weather.temp.roundToInt()}\u00B0",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = TextWhite
            )
        }
    }
}
