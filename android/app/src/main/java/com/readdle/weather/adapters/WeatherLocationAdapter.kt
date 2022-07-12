package com.readdle.weather.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.annotation.DrawableRes
import androidx.recyclerview.widget.RecyclerView
import com.readdle.weather.R
import com.readdle.weather.core.Location
import com.readdle.weather.core.LocationWeatherData
import com.readdle.weather.core.WeatherState
import kotlin.math.round

class WeatherLocationAdapter(private var weathers: List<LocationWeatherData>,
                             private var onLongClickListener: (Location) -> Unit) :
    RecyclerView.Adapter<WeatherLocationAdapter.LocationViewHolder>() {

    // Provide a reference to the views for each data item
    // Complex data items may need more than one view per item, and
    // you provide access to all the views for a data item in a view holder.
    // Each data item is just a string in this case that is shown in a TextView.
    class LocationViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val weatherState: ImageView = itemView.findViewById(R.id.weatherState)
        val titleText: TextView = itemView.findViewById(R.id.title)
        val tempText: TextView = itemView.findViewById(R.id.temp)
        val progress: ProgressBar = itemView.findViewById(R.id.loading)
    }


    // Create new views (invoked by the layout manager)
    override fun onCreateViewHolder(parent: ViewGroup,
                                    viewType: Int): LocationViewHolder {
        val textView = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_location, parent, false)
        return LocationViewHolder(
            textView
        )
    }

    // Replace the contents of a view (invoked by the layout manager)
    override fun onBindViewHolder(holder: LocationViewHolder, position: Int) {
        // - get element from your dataset at this position
        // - replace the contents of the view with that element

        val location = weathers[position].location
        holder.titleText.text = location.title
        val weather = weathers[position].weather
        if (weather != null) {
            holder.weatherState.setImageResource(getDrawableForWeatherState(weather.state))
            holder.tempText.text = "${round(weather.temp).toInt()} °C"
            holder.progress.visibility = View.GONE
            holder.weatherState.visibility = View.VISIBLE
        }
        else {
            holder.progress.visibility = View.VISIBLE
            holder.weatherState.visibility = View.GONE
            holder.tempText.text = "-- °C"
        }
        holder.itemView.setOnLongClickListener {
            onLongClickListener(location)
            return@setOnLongClickListener true
        }
    }

    // Return the size of your dataset (invoked by the layout manager)
    override fun getItemCount() = weathers.size

    fun swapWeathers(weathers: List<LocationWeatherData>) {
        this.weathers = weathers
        notifyDataSetChanged()
    }

    @DrawableRes
    private fun getDrawableForWeatherState(state: WeatherState): Int {
        return when (state) {
            WeatherState.NONE -> R.drawable.ic_sync
            WeatherState.SNOW -> R.drawable.ic_sn
            WeatherState.THUNDERSTORM -> R.drawable.ic_t
            WeatherState.SHOWERS -> R.drawable.ic_s
            WeatherState.CLEAR -> R.drawable.ic_c
            WeatherState.DRIZZLE -> R.drawable.ic_lr
            WeatherState.RAIN -> R.drawable.ic_hr
            WeatherState.CLOUDS -> R.drawable.ic_hc
            WeatherState.ATMOSPHERE -> R.drawable.ic_lc
        }
    }
}