package com.readdle.weather

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.readdle.weather.core.*

class MainViewModel @ViewModelInject constructor(
    container: SwiftContainer
) : ViewModel(), LocationWeatherViewModelDelegateAndroid, LocationSearchDelegateAndroid {

    private val locationWeatherViewModel = container.getWeatherViewModel(this)
    private val locationSearchViewModel = container.getLocationSearchViewModel(this)

    private val weatherLiveData = MutableLiveData<List<LocationWeatherData>>()
    private val searchSuggestionLiveData = MutableLiveData<List<Location>>()
    private val errorDescriptionLiveData = MutableLiveData<String>()

    override fun onCleared() {
        super.onCleared()
        locationWeatherViewModel.release()
        locationSearchViewModel.release()
    }

    fun getWeatherLiveData() : LiveData<List<LocationWeatherData>> {
        return weatherLiveData
    }

    fun getSearchSuggestionLiveData() : LiveData<List<Location>> {
        return searchSuggestionLiveData
    }

    fun getErrorDescriptionLiveData() : LiveData<String> {
        return errorDescriptionLiveData
    }

    override fun onSuggestionStateChanged(state: ArrayList<Location>) {
        searchSuggestionLiveData.postValue(state)
    }

    override fun onWeatherStateChanged(state: ArrayList<LocationWeatherData>) {
        weatherLiveData.postValue(state)
    }

    override fun onError(errorDescription: String) {
        errorDescriptionLiveData.postValue(errorDescription)
    }

    fun searchLocations(newText: String?) {
        locationSearchViewModel.searchLocations(newText)
    }

    fun addLocation(location: Location) {
        locationWeatherViewModel.addLocationToSaved(location)
    }

    fun removeLocation(location: Location) {
        locationWeatherViewModel.removeSavedLocation(location)
    }

}