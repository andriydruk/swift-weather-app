//
//  WeatherDetailView.swift
//  Shared
//

import SwiftUI
import WeatherCore

struct WeatherDetailView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    let initialPage: Int
    let onBack: () -> Void
    @Binding var showSearch: Bool

    @State private var currentPage: Int = 0

    var body: some View {
        ZStack {
            Color.weatherBlue.ignoresSafeArea()

            if viewModel.locations.isEmpty {
                emptyState
            } else {
                pagerContent
            }

            // Top bar overlay
            VStack {
                topBar
                Spacer()
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .onAppear { currentPage = initialPage }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 60))
                .foregroundColor(.textWhite70)
            Text("No cities added")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.textWhite)
            Text("Tap search to add a city")
                .font(.system(size: 14))
                .foregroundColor(.textWhite70)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "list.bullet")
                    .font(.title3)
                    .foregroundColor(.textWhite)
            }
            Spacer()
            Button(action: { showSearch = true }) {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundColor(.textWhite)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Pager

    private var pagerContent: some View {
        ZStack(alignment: .bottom) {
            #if os(iOS)
            TabView(selection: $currentPage) {
                ForEach(Array(viewModel.locations.enumerated()), id: \.element.location.woeId) { index, data in
                    WeatherPageContent(data: data)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: currentPage) { newValue in
                viewModel.currentPageIndex = newValue
            }

            // Page dots
            if viewModel.locations.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.locations.count, id: \.self) { i in
                        Circle()
                            .fill(i == currentPage ? Color.textWhite : Color.textWhite50)
                            .frame(width: i == currentPage ? 8 : 6, height: i == currentPage ? 8 : 6)
                    }
                }
                .padding(.bottom, 16)
            }
            #else
            if currentPage < viewModel.locations.count {
                WeatherPageContent(data: viewModel.locations[currentPage])
            }
            #endif
        }
    }
}

// MARK: - Weather Page Content

private struct WeatherPageContent: View {
    let data: LocationWeatherData

    private var weather: Weather? { data.weather }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroSection
                    .padding(.top, 48)
                    .padding(.bottom, 20)

                hourlyForecastCard
                    .padding(.horizontal, 16)

                Spacer().frame(height: 12)

                dailyForecastCard
                    .padding(.horizontal, 16)

                Spacer().frame(height: 12)

                detailCardsGrid
                    .padding(.horizontal, 16)

                Spacer().frame(height: 60)
            }
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 4) {
            Text(cityName(data.location.title))
                .font(.system(size: 36, weight: .medium))
                .foregroundColor(.textWhite)
                .lineLimit(1)
                .padding(.horizontal, 16)

            HStack(spacing: 8) {
                Image(systemName: weatherIconName(weather?.state))
                    .font(.system(size: 60))
                    .foregroundColor(weatherIconColor(weather?.state))
                    .frame(width: 80, height: 80)

                Text(weather != nil ? "\(Int(weather!.temp.rounded()))°" : "--°")
                    .font(.system(size: 96, weight: .bold))
                    .foregroundColor(.textWhite)
                    .tracking(-4)
            }

            Text(weather != nil ? "Feels like \(Int(weather!.feelsLike.rounded()))°" : "")
                .font(.system(size: 18))
                .foregroundColor(.textWhite70)
        }
    }

    // MARK: - Hourly Forecast Card

    private var hourlyForecastCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hourly Forecast")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textWhite70)
                .tracking(0.5)

            Divider()
                .background(Color.textWhite50.opacity(0.3))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    if let weather = weather, !weather.hourlyForecasts.isEmpty {
                        ForEach(Array(weather.hourlyForecasts.enumerated()), id: \.offset) { _, forecast in
                            HourlyItem(
                                time: hourlyFormatter.string(from: forecast.date),
                                temp: "\(Int(forecast.temp.rounded()))°",
                                state: forecast.state
                            )
                        }
                    } else {
                        // Placeholder
                        ForEach(["Now", "3PM", "6PM", "9PM", "12AM", "3AM"], id: \.self) { hour in
                            HourlyItem(
                                time: hour,
                                temp: weather != nil ? "\(Int(weather!.temp.rounded()))°" : "--°",
                                state: weather?.state
                            )
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.cardOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Daily Forecast Card

    private var dailyForecastCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("5-Day Forecast")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textWhite70)
                .tracking(0.5)

            Divider()
                .background(Color.textWhite50.opacity(0.3))
                .padding(.vertical, 8)

            if let weather = weather, !weather.dailyForecasts.isEmpty {
                ForEach(Array(weather.dailyForecasts.enumerated()), id: \.offset) { index, forecast in
                    DailyForecastRow(
                        dayName: index == 0 ? "Today" : dayFormatter.string(from: forecast.date),
                        state: forecast.state,
                        low: "\(Int(forecast.minTemp.rounded()))°",
                        high: "\(Int(forecast.maxTemp.rounded()))°"
                    )
                    if index < weather.dailyForecasts.count - 1 {
                        Divider()
                            .background(Color.textWhite50.opacity(0.2))
                            .padding(.vertical, 4)
                    }
                }
            } else {
                // Placeholder
                let days = ["Today", "Tuesday", "Wednesday", "Thursday", "Friday"]
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    DailyForecastRow(
                        dayName: day,
                        state: weather?.state,
                        low: "--°",
                        high: "--°"
                    )
                    if index < days.count - 1 {
                        Divider()
                            .background(Color.textWhite50.opacity(0.2))
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.cardOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Detail Cards Grid

    private var detailCardsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                DetailCard(
                    title: "FEELS LIKE",
                    icon: "thermometer.sun.fill",
                    value: weather != nil ? "\(Int(weather!.feelsLike.rounded()))" : "--",
                    unit: "°",
                    description: ""
                )
                DetailCard(
                    title: "HUMIDITY",
                    icon: "humidity.fill",
                    value: weather != nil ? "\(Int(weather!.humidity.rounded()))" : "--",
                    unit: "%",
                    description: weather != nil ? humidityDescription(weather!.humidity) : ""
                )
            }
            .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                DetailCard(
                    title: "WIND",
                    icon: "wind",
                    value: weather != nil ? "\(Int(weather!.windSpeed.rounded()))" : "--",
                    unit: " m/s",
                    description: windDirection(weather?.windDirection ?? 0)
                )
                DetailCard(
                    title: "PRESSURE",
                    icon: "gauge.medium",
                    value: weather != nil ? "\(Int(weather!.airPressure.rounded()))" : "--",
                    unit: "",
                    description: "hPa"
                )
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Hourly Item

private struct HourlyItem: View {
    let time: String
    let temp: String
    let state: WeatherState?

    var body: some View {
        VStack(spacing: 8) {
            Text(time)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textWhite70)

            Image(systemName: weatherIconName(state))
                .font(.system(size: 20))
                .foregroundColor(weatherIconColor(state))
                .frame(width: 28, height: 28)

            Text(temp)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textWhite)
        }
    }
}

// MARK: - Daily Forecast Row

private struct DailyForecastRow: View {
    let dayName: String
    let state: WeatherState?
    let low: String
    let high: String

    var body: some View {
        HStack {
            Text(dayName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.textWhite)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: weatherIconName(state))
                .font(.system(size: 20))
                .foregroundColor(weatherIconColor(state))
                .frame(width: 28, height: 28)

            Spacer().frame(width: 20)

            Text(low)
                .font(.system(size: 18))
                .foregroundColor(.textWhite50)
                .frame(width: 42, alignment: .trailing)

            Spacer().frame(width: 8)

            Text(high)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textWhite)
                .frame(width: 42, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Detail Card

private struct DetailCard: View {
    let title: String
    let icon: String
    let value: String
    let unit: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.textWhite70)
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textWhite70)
                    .tracking(0.5)
            }

            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.textWhite)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 18))
                        .foregroundColor(.textWhite70)
                        .padding(.bottom, 4)
                }
            }

            if !description.isEmpty {
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textWhite70)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.cardOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Private Helpers

private func cityName(_ title: String) -> String {
    title.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? title
}
