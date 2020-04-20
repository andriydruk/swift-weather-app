package com.readdle.weather.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.readdle.weather.R
import com.readdle.weather.core.Location

class SearchLocationAdapter(private var locations: List<Location>,
                            private var onClickListener: (Location) -> Unit) :
    RecyclerView.Adapter<SearchLocationAdapter.LocationViewHolder>() {

    class LocationViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val titleText: TextView = itemView.findViewById(R.id.title)
    }

    override fun onCreateViewHolder(parent: ViewGroup,
                                    viewType: Int): LocationViewHolder {
        val textView = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_search_location, parent, false)
        return LocationViewHolder(
            textView
        )
    }

    override fun onBindViewHolder(holder: LocationViewHolder, position: Int) {
        val location = locations[position]
        holder.titleText.text = location.title
        holder.itemView.setOnClickListener {
            onClickListener(location)
        }
    }

    override fun getItemCount() = locations.size

    fun swapLocations(locations: List<Location>) {
        this.locations = locations
        notifyDataSetChanged()
    }

}