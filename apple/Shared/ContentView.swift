//
//  ContentView.swift
//  Shared
//
//  Created by Andrius Shiaulis on 04.07.2020.
//

import SwiftUI
import WeatherCore

struct ContentView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    @State private var showSearch = false
    @State private var pendingLocation: Location?
    @State private var selectedIndex: Int? = nil

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var navigationPath = NavigationPath()
    #endif

    var body: some View {
        #if os(iOS)
        if horizontalSizeClass == .regular {
            splitViewContent
        } else {
            phoneContent
        }
        #else
        splitViewContent
        #endif
    }

    // MARK: - iPhone (Compact) - NavigationStack + push

    #if os(iOS)
    private var phoneContent: some View {
        NavigationStack(path: $navigationPath) {
            CityListView(
                selectedIndex: $selectedIndex,
                onCitySelected: { index in
                    navigationPath.append(index)
                },
                showSearch: $showSearch
            )
            .navigationDestination(for: Int.self) { pageIndex in
                WeatherDetailView(
                    initialPage: pageIndex,
                    onBack: { navigationPath.removeLast() },
                    showSearch: $showSearch
                )
            }
        }
        .sheet(isPresented: $showSearch, onDismiss: handleSearchDismissed) {
            SearchView(showSearch: $showSearch) { location in
                pendingLocation = location
            }
        }
        .alert("Error", isPresented: errorBinding) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .preferredColorScheme(.dark)
    }
    #endif

    // MARK: - iPad / macOS - NavigationSplitView

    private var splitViewContent: some View {
        NavigationSplitView {
            CityListView(
                selectedIndex: $selectedIndex,
                onCitySelected: { index in
                    selectedIndex = index
                },
                showSearch: $showSearch
            )
            .navigationSplitViewColumnWidth(min: 300, ideal: 340, max: 420)
        } detail: {
            ZStack {
                Color.weatherBlue.ignoresSafeArea()

                if let index = selectedIndex, index < viewModel.locations.count {
                    SplitDetailView(data: viewModel.locations[index])
                } else if !viewModel.locations.isEmpty {
                    SplitDetailView(data: viewModel.locations[0])
                        .onAppear { selectedIndex = 0 }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.textWhite70)
                        Text("No cities added")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.textWhite)
                        Text("Use search to add a city")
                            .font(.system(size: 14))
                            .foregroundColor(.textWhite70)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showSearch = true }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
        .sheet(isPresented: $showSearch, onDismiss: handleSearchDismissed) {
            SearchView(showSearch: $showSearch) { location in
                pendingLocation = location
            }
            #if os(macOS)
            .frame(minWidth: 400, minHeight: 500)
            #endif
        }
        .alert("Error", isPresented: errorBinding) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.locations.count) { _ in
            if selectedIndex == nil && !viewModel.locations.isEmpty {
                selectedIndex = 0
            }
            if let idx = selectedIndex, idx >= viewModel.locations.count {
                selectedIndex = viewModel.locations.isEmpty ? nil : viewModel.locations.count - 1
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Shared

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )
    }

    private func handleSearchDismissed() {
        guard let location = pendingLocation else { return }
        pendingLocation = nil

        #if os(iOS)
        navigationPath = NavigationPath()
        #endif

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let index = viewModel.findExistingCityIndex(location) {
                #if os(iOS)
                if horizontalSizeClass == .regular {
                    selectedIndex = index
                } else {
                    navigationPath.append(index)
                }
                #else
                selectedIndex = index
                #endif
            }
        }
    }
}

// MARK: - Split Detail View (iPad + macOS)

private struct SplitDetailView: View {
    let data: LocationWeatherData

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                hourlyForecastCard
                    .padding(.horizontal, 24)

                Spacer().frame(height: 12)

                dailyForecastCard
                    .padding(.horizontal, 24)

                Spacer().frame(height: 12)

                detailCardsGrid
                    .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
    }

    private var weather: Weather? { data.weather }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 4) {
            Text(splitCityName(data.location.title))
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.textWhite)
                .lineLimit(1)

            HStack(spacing: 8) {
                Image(systemName: weatherIconName(weather?.state))
                    .font(.system(size: 50))
                    .foregroundColor(weatherIconColor(weather?.state))
                    .frame(width: 70, height: 70)

                Text(weather != nil ? "\(Int(weather!.temp.rounded()))°" : "--°")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.textWhite)
                    .tracking(-4)
            }

            Text(weather != nil ? "Feels like \(Int(weather!.feelsLike.rounded()))°" : "")
                .font(.system(size: 16))
                .foregroundColor(.textWhite70)
        }
    }

    // MARK: - Hourly

    private var hourlyForecastCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hourly Forecast")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textWhite70)
                .tracking(0.5)

            Divider().background(Color.textWhite50.opacity(0.3))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    if let weather = weather, !weather.hourlyForecasts.isEmpty {
                        ForEach(Array(weather.hourlyForecasts.enumerated()), id: \.offset) { _, forecast in
                            splitHourlyItem(
                                time: hourlyFormatter.string(from: forecast.date),
                                temp: "\(Int(forecast.temp.rounded()))°",
                                state: forecast.state
                            )
                        }
                    } else {
                        ForEach(["Now", "3PM", "6PM", "9PM", "12AM", "3AM"], id: \.self) { hour in
                            splitHourlyItem(time: hour, temp: "--°", state: weather?.state)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.cardOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func splitHourlyItem(time: String, temp: String, state: WeatherState?) -> some View {
        VStack(spacing: 6) {
            Text(time)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.textWhite70)
            Image(systemName: weatherIconName(state))
                .font(.system(size: 18))
                .foregroundColor(weatherIconColor(state))
                .frame(width: 24, height: 24)
            Text(temp)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textWhite)
        }
    }

    // MARK: - Daily

    private var dailyForecastCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("5-Day Forecast")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textWhite70)
                .tracking(0.5)

            Divider()
                .background(Color.textWhite50.opacity(0.3))
                .padding(.vertical, 8)

            if let weather = weather, !weather.dailyForecasts.isEmpty {
                ForEach(Array(weather.dailyForecasts.enumerated()), id: \.offset) { index, forecast in
                    splitDailyRow(
                        day: index == 0 ? "Today" : dayFormatter.string(from: forecast.date),
                        state: forecast.state,
                        low: "\(Int(forecast.minTemp.rounded()))°",
                        high: "\(Int(forecast.maxTemp.rounded()))°"
                    )
                    if index < weather.dailyForecasts.count - 1 {
                        Divider().background(Color.textWhite50.opacity(0.2)).padding(.vertical, 4)
                    }
                }
            } else {
                ForEach(["Today", "Tuesday", "Wednesday", "Thursday", "Friday"], id: \.self) { day in
                    splitDailyRow(day: day, state: weather?.state, low: "--°", high: "--°")
                }
            }
        }
        .padding(12)
        .background(Color.cardOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func splitDailyRow(day: String, state: WeatherState?, low: String, high: String) -> some View {
        HStack {
            Text(day)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textWhite)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: weatherIconName(state))
                .font(.system(size: 18))
                .foregroundColor(weatherIconColor(state))
                .frame(width: 24, height: 24)
            Spacer().frame(width: 16)
            Text(low)
                .font(.system(size: 15))
                .foregroundColor(.textWhite50)
                .frame(width: 38, alignment: .trailing)
            Spacer().frame(width: 8)
            Text(high)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textWhite)
                .frame(width: 38, alignment: .trailing)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Detail Cards

    private var detailCardsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                splitDetailCard(title: "FEELS LIKE", icon: "thermometer.sun.fill",
                                value: weather != nil ? "\(Int(weather!.feelsLike.rounded()))" : "--",
                                unit: "°", description: "")
                splitDetailCard(title: "HUMIDITY", icon: "humidity.fill",
                                value: weather != nil ? "\(Int(weather!.humidity.rounded()))" : "--",
                                unit: "%", description: weather != nil ? humidityDescription(weather!.humidity) : "")
            }
            .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 12) {
                splitDetailCard(title: "WIND", icon: "wind",
                                value: weather != nil ? "\(Int(weather!.windSpeed.rounded()))" : "--",
                                unit: " m/s", description: windDirection(weather?.windDirection ?? 0))
                splitDetailCard(title: "PRESSURE", icon: "gauge.medium",
                                value: weather != nil ? "\(Int(weather!.airPressure.rounded()))" : "--",
                                unit: "", description: "hPa")
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func splitDetailCard(title: String, icon: String, value: String, unit: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 12)).foregroundColor(.textWhite70)
                Text(title).font(.system(size: 12, weight: .semibold)).foregroundColor(.textWhite70).tracking(0.5)
            }
            HStack(alignment: .bottom, spacing: 2) {
                Text(value).font(.system(size: 28, weight: .bold)).foregroundColor(.textWhite)
                if !unit.isEmpty {
                    Text(unit).font(.system(size: 15)).foregroundColor(.textWhite70).padding(.bottom, 3)
                }
            }
            if !description.isEmpty {
                Text(description).font(.system(size: 13, weight: .medium)).foregroundColor(.textWhite70)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.cardOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private func splitCityName(_ title: String) -> String {
    title.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? title
}
