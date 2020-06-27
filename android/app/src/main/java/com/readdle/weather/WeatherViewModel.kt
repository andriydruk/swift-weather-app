package com.readdle.weather

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.readdle.weather.core.*

class WeatherViewModel @ViewModelInject constructor(
    db: JSONStorage,
    provider: MetaWeatherProvider) : ViewModel(), WeatherRepositoryDelegateAndroid {

    private val weatherRepository = WeatherRepository.init(db, provider, this)

    private val errorDescription = MutableLiveData<String>()
    private val searchSuggestion = MutableLiveData<List<Location>>()
    private val savedLocations: MutableLiveData<List<Location>> by lazy {
        MutableLiveData<List<Location>>().also {
            weatherRepository.loadSavedLocations()
        }
    }
    private val weatherMap = MutableLiveData<Map<Long, Weather>>()

    private val actuallyWeathers = HashMap<Long, Weather>();

    override fun onCleared() {
        super.onCleared()
        weatherRepository.release()
    }

    fun getSavedLocations(): LiveData<List<Location>> {
        return savedLocations
    }

    fun getSearchSuggestion(): LiveData<List<Location>> {
        return searchSuggestion
    }

    fun getWeatherMap(): LiveData<Map<Long, Weather>> {
        return weatherMap
    }

    fun getErrorDescription(): LiveData<String> {
        return errorDescription
    }

    fun addLocation(location: Location) {
        weatherRepository.addLocationToSaved(location)
    }

    fun removeLocation(location: Location) {
        weatherRepository.removeSavedLocation(location)
    }

    fun searchLocations(query: String?) {
        weatherRepository.searchLocations(query)
    }

    override fun onSearchSuggestionChanged(locations: ArrayList<Location>) {
        this.searchSuggestion.postValue(locations)
    }

    override fun onSavedLocationChanged(locations: ArrayList<Location>) {
        this.savedLocations.postValue(locations)
    }

    override fun onError(errorDescription: String) {
        this.errorDescription.postValue(errorDescription)
    }

    override fun onWeatherChanged(woeId: Long, weather: Weather) {
        val map = synchronized(this) {
            actuallyWeathers[woeId] = weather
            HashMap(actuallyWeathers)
        }
        weatherMap.postValue(map)
    }
}