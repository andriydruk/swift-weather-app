//
//  CityListView.swift
//  Shared
//

import SwiftUI
import WeatherCore

struct CityListView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    @Binding var selectedIndex: Int?
    var onCitySelected: (Int) -> Void
    @Binding var showSearch: Bool

    var body: some View {
        ZStack {
            Color.weatherBlue.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Weather")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.textWhite)
                        .tracking(-0.5)

                    Spacer()

                    Button(action: { showSearch = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.textWhite)
                    }
                    #if os(macOS)
                    .buttonStyle(.plain)
                    #endif
                }
                .padding(.horizontal, 16)
                .frame(height: 56)

                // City List
                List {
                    ForEach(Array(viewModel.locations.enumerated()), id: \.element.location.woeId) { index, data in
                        CityRow(data: data, isSelected: selectedIndex == index)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onCitySelected(index)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            #if os(iOS)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.removeLocation(data.location)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            #endif
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.removeLocation(data.location)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
    }
}

// MARK: - City Row

private struct CityRow: View {
    let data: LocationWeatherData
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(cityName(data.location.title))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textWhite)
                    .lineLimit(1)

                Text(weatherDescription(data.weather?.state))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textWhite70)
            }

            Spacer()

            HStack(spacing: 0) {
                Image(systemName: weatherIconName(data.weather?.state))
                    .font(.system(size: 28))
                    .foregroundColor(weatherIconColor(data.weather?.state))
                    .frame(width: 36, height: 36)

                if let weather = data.weather {
                    Text("\(Int(weather.minTemp.rounded()))°")
                        .font(.system(size: 20))
                        .foregroundColor(.textWhite70)
                        .frame(width: 52, alignment: .trailing)

                    Text("\(Int(weather.maxTemp.rounded()))°")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.textWhite)
                        .frame(width: 52, alignment: .trailing)
                } else {
                    Spacer().frame(width: 60)
                    ProgressView()
                        .tint(.white)
                        .frame(width: 24, height: 24)
                }
            }
            .frame(width: 170)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(isSelected ? Color.white.opacity(0.25) : Color.weatherCardBlue)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isSelected ? Color.white.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Helpers

private func cityName(_ title: String) -> String {
    title.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? title
}
