package com.readdle.weather

import android.util.Log
import androidx.lifecycle.ViewModel
import com.readdle.weather.core.*
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    container: SwiftContainer
) : ViewModel(), LocationWeatherViewModelDelegateAndroid, LocationSearchDelegateAndroid {

    private val locationWeatherViewModel = container.getWeatherViewModel(this)
    private val locationSearchViewModel = container.getLocationSearchViewModel(this)

    private val _weatherState = MutableStateFlow<List<LocationWeatherData>>(emptyList())
    val weatherState: StateFlow<List<LocationWeatherData>> = _weatherState.asStateFlow()

    private val _searchSuggestions = MutableStateFlow<List<LocationWeatherData>>(emptyList())
    val searchSuggestions: StateFlow<List<LocationWeatherData>> = _searchSuggestions.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val _selectedLocation = MutableStateFlow<LocationWeatherData?>(null)
    val selectedLocation: StateFlow<LocationWeatherData?> = _selectedLocation.asStateFlow()

    private val _currentPageIndex = MutableStateFlow(0)
    val currentPageIndex: StateFlow<Int> = _currentPageIndex.asStateFlow()

    override fun onCleared() {
        super.onCleared()
        locationWeatherViewModel.release()
        locationSearchViewModel.release()
    }

    override fun onSuggestionStateChanged(state: ArrayList<LocationWeatherData>) {
        _searchSuggestions.value = state
    }

    override fun onWeatherStateChanged(state: ArrayList<LocationWeatherData>) {
        _weatherState.value = state
    }

    override fun onError(errorDescription: String) {
        _errorMessage.value = errorDescription
    }

    fun clearError() {
        _errorMessage.value = null
    }

    fun searchLocations(newText: String?) {
        locationSearchViewModel.searchLocations(newText)
    }

    fun addLocation(location: Location) {
        locationWeatherViewModel.addLocationToSaved(location)
    }

    fun findExistingCityIndex(location: Location): Int {
        return _weatherState.value.indexOfFirst {
            Math.abs(it.location.latitude - location.latitude) < 0.1f &&
            Math.abs(it.location.longitude - location.longitude) < 0.1f
        }
    }

    fun removeLocation(location: Location) {
        Log.i("TAG", "remove location!!!")
        locationWeatherViewModel.removeSavedLocation(location)
    }

    fun selectLocation(data: LocationWeatherData) {
        _selectedLocation.value = data
    }

    fun clearSelection() {
        _selectedLocation.value = null
    }

    fun setCurrentPage(index: Int) {
        _currentPageIndex.value = index
    }
}