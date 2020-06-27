package com.readdle.weather

import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import androidx.activity.viewModels
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.SearchView
import androidx.core.view.MenuItemCompat
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.snackbar.Snackbar
import com.readdle.weather.adapters.SearchLocationAdapter
import com.readdle.weather.adapters.WeatherLocationAdapter
import com.readdle.weather.core.Location
import com.readdle.weather.core.Weather
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : AppCompatActivity() {

    private lateinit var recycler: RecyclerView
    private lateinit var weatherLocationAdapter: WeatherLocationAdapter
    private lateinit var searchLocationAdapter: SearchLocationAdapter

    private val model: WeatherViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val viewManager = LinearLayoutManager(this)
        weatherLocationAdapter = WeatherLocationAdapter(emptyList(), emptyMap()) {
            removeLocation(it)
        }

        recycler = findViewById<RecyclerView>(R.id.recycler_view).apply {
            // use this setting to improve performance if you know that changes
            // in content do not change the layout size of the RecyclerView
            setHasFixedSize(true)

            // use a linear layout manager
            layoutManager = viewManager

            // specify an viewAdapter (see also next example)
            adapter = weatherLocationAdapter
        }

        model.getSavedLocations().observe(this, Observer<List<Location>> {
            weatherLocationAdapter.swapLocations(it)
        })
        model.getWeatherMap().observe(this, Observer<Map<Long, Weather>> {
            weatherLocationAdapter.swapWeatherMap(it)
        })
        model.getSearchSuggestion().observe(this, Observer<List<Location>> {
            searchLocationAdapter.swapLocations(it)
        })
        model.getErrorDescription().observe(this, Observer<String> {
            Snackbar.make(recycler, it, Snackbar.LENGTH_SHORT).show()
        })
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        val inflater = menuInflater
        inflater.inflate(R.menu.action_menu, menu)
        val searchViewItem: MenuItem = menu.findItem(R.id.app_bar_search)
        val searchView: SearchView = searchViewItem.actionView as SearchView
        searchView.setOnCloseListener {
            recycler.adapter = weatherLocationAdapter
            return@setOnCloseListener false
        }
        searchView.setOnSearchClickListener {
            recycler.adapter = searchLocationAdapter
        }

        searchLocationAdapter = SearchLocationAdapter(emptyList()) {
            searchView.onActionViewCollapsed()
            recycler.adapter = weatherLocationAdapter
            addLocation(it)
        }

        searchView.setOnQueryTextListener(object: SearchView.OnQueryTextListener {

            override fun onQueryTextChange(newText: String?): Boolean {
                model.searchLocations(newText)
                return true
            }

            override fun onQueryTextSubmit(query: String?): Boolean {
                return true
            }

        })
        return super.onCreateOptionsMenu(menu)
    }

    private fun addLocation(location: Location) {
        model.addLocation(location)
        Snackbar.make(recycler, location.title + " was added", Snackbar.LENGTH_SHORT).show()
    }

    private fun removeLocation(location: Location) {
        AlertDialog.Builder(this)
            .setMessage("Are you sure you want to delete " + location.title + " from saved?")
            .setPositiveButton("Yes") { dialog, _ ->
                model.removeLocation(location)
                Snackbar.make(recycler, location.title + " was removed", Snackbar.LENGTH_SHORT).show()
                dialog.dismiss()
            }
            .setNegativeButton("No") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
    }

}
