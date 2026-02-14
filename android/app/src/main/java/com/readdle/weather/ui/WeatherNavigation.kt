package com.readdle.weather.ui

import androidx.compose.animation.ExperimentalSharedTransitionApi
import androidx.compose.animation.SharedTransitionLayout
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.readdle.weather.MainViewModel
import com.readdle.weather.ui.screens.CityListScreen
import com.readdle.weather.ui.screens.SearchScreen
import com.readdle.weather.ui.screens.WeatherMainScreen

sealed class Screen(val route: String) {
    data object CityList : Screen("city_list")
    data object Main : Screen("main")
    data object Search : Screen("search")
}

fun cityBoundsKey(index: Int): String = "city_bounds_$index"

@OptIn(ExperimentalSharedTransitionApi::class)
@Composable
fun WeatherNavigation(
    viewModel: MainViewModel = hiltViewModel(),
    modifier: Modifier = Modifier
) {
    val navController = rememberNavController()
    val weatherState by viewModel.weatherState.collectAsStateWithLifecycle()
    val searchSuggestions by viewModel.searchSuggestions.collectAsStateWithLifecycle()
    val errorMessage by viewModel.errorMessage.collectAsStateWithLifecycle()
    val currentPageIndex by viewModel.currentPageIndex.collectAsStateWithLifecycle()

    LaunchedEffect(errorMessage) {
        errorMessage?.let { viewModel.clearError() }
    }

    SharedTransitionLayout(modifier = modifier) {
        val sharedScope = this
        NavHost(
            navController = navController,
            startDestination = Screen.CityList.route,
            enterTransition = { slideInHorizontally(initialOffsetX = { it }) + fadeIn() },
            exitTransition = { slideOutHorizontally(targetOffsetX = { -it / 3 }) + fadeOut() },
            popEnterTransition = { slideInHorizontally(initialOffsetX = { -it / 3 }) + fadeIn() },
            popExitTransition = { slideOutHorizontally(targetOffsetX = { it }) + fadeOut() }
        ) {
            // City list is the home screen
            composable(
                route = Screen.CityList.route,
                enterTransition = { fadeIn() },
                exitTransition = { fadeOut() },
                popEnterTransition = { fadeIn() },
                popExitTransition = { fadeOut() }
            ) { navBackStackEntry ->
                CityListScreen(
                    locations = weatherState,
                    currentPageIndex = currentPageIndex,
                    onCityClick = { index ->
                        viewModel.setCurrentPage(index)
                        navController.navigate(Screen.Main.route)
                    },
                    onAddClick = { navController.navigate(Screen.Search.route) },
                    onRemoveCity = { location -> viewModel.removeLocation(location) },
                    sharedTransitionScope = sharedScope,
                    animatedVisibilityScope = this
                )
            }

            // Weather detail - city card expands to full screen
            composable(
                route = Screen.Main.route,
                enterTransition = { fadeIn() },
                exitTransition = { fadeOut() },
                popEnterTransition = { fadeIn() },
                popExitTransition = { fadeOut() }
            ) { navBackStackEntry ->
                WeatherMainScreen(
                    allLocations = weatherState,
                    initialPage = currentPageIndex,
                    onPageChanged = { viewModel.setCurrentPage(it) },
                    onMenuClick = { navController.popBackStack() },
                    onSearchClick = { navController.navigate(Screen.Search.route) },
                    sharedTransitionScope = sharedScope,
                    animatedVisibilityScope = this
                )
            }

            composable(Screen.Search.route) {
                SearchScreen(
                    suggestions = searchSuggestions,
                    savedLocations = weatherState,
                    onQueryChange = { viewModel.searchLocations(it) },
                    onLocationAdd = { location ->
                        val existingIndex = viewModel.findExistingCityIndex(location)
                        if (existingIndex >= 0) {
                            // City already exists - navigate to it
                            viewModel.setCurrentPage(existingIndex)
                            navController.popBackStack()
                            navController.navigate(Screen.Main.route)
                        } else {
                            // New city - add and open its detail view
                            val newIndex = weatherState.size // will be appended at end
                            viewModel.addLocation(location)
                            viewModel.setCurrentPage(newIndex)
                            navController.popBackStack()
                            navController.navigate(Screen.Main.route)
                        }
                    },
                    onLocationClick = { data ->
                        val index = weatherState.indexOf(data)
                        if (index >= 0) {
                            viewModel.setCurrentPage(index)
                            // Pop search, then navigate to weather
                            navController.popBackStack()
                            navController.navigate(Screen.Main.route)
                        }
                    },
                    onBack = { navController.popBackStack() }
                )
            }
        }
    }
}
