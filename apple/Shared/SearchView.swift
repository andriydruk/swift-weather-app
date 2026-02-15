//
//  SearchView.swift
//  Shared
//

import SwiftUI
import WeatherCore

struct SearchView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    @Binding var showSearch: Bool
    var onLocationSelected: ((Location) -> Void)?

    @State private var query: String = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            Color.weatherBlue.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                searchField
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                resultsList
            }
            .onAppear {
                isSearchFocused = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Search")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.textWhite)
                .tracking(-0.5)

            Spacer()

            Button(action: { showSearch = false }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textWhite70)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    // MARK: - Search Field

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18))
                .foregroundColor(.textWhite50)

            TextField("Enter city name...", text: $query)
                .textFieldStyle(.plain)
                .font(.system(size: 17))
                .foregroundColor(.textWhite)
                .tint(.white)
                .focused($isSearchFocused)
                #if os(iOS)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                #endif
                .onChange(of: query) { newValue in
                    viewModel.searchLocations(newValue)
                }

            if !query.isEmpty {
                Button(action: {
                    query = ""
                    viewModel.searchLocations("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.textWhite50)
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color.cardOverlay)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Results List

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if !query.isEmpty {
                    if !viewModel.suggestions.isEmpty {
                        sectionHeader("Results")
                        ForEach(viewModel.suggestions, id: \.location.woeId) { data in
                            SuggestionRow(data: data) {
                                viewModel.addLocation(data.location)
                                onLocationSelected?(data.location)
                                showSearch = false
                            }
                        }
                    } else if query.count < 2 {
                        placeholderText("Type city name to search")
                    } else {
                        placeholderText("No cities found")
                    }
                } else if !viewModel.locations.isEmpty {
                    sectionHeader("Saved Cities")
                    ForEach(viewModel.locations, id: \.location.woeId) { data in
                        SavedCityRow(data: data) {
                            onLocationSelected?(data.location)
                            showSearch = false
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.textWhite70)
            .tracking(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
    }

    // MARK: - Placeholder Text

    private func placeholderText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.textWhite50)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
    }
}

// MARK: - Suggestion Row

private struct SuggestionRow: View {
    let data: LocationWeatherData
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                HStack(spacing: 12) {
                    if let weather = data.weather {
                        Image(systemName: weatherIconName(weather.state))
                            .font(.system(size: 22))
                            .foregroundColor(weatherIconColor(weather.state))
                            .frame(width: 28, height: 28)
                    } else {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.textWhite70)
                            .frame(width: 28, height: 28)
                    }

                    Text(data.location.title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.textWhite)
                        .lineLimit(1)
                }

                Spacer()

                if let weather = data.weather {
                    Text("\(Int(weather.temp.rounded()))°")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.textWhite)
                } else {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.textWhite70)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.cardOverlay)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }
}

// MARK: - Saved City Row

private struct SavedCityRow: View {
    let data: LocationWeatherData
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: weatherIconName(data.weather?.state))
                        .font(.system(size: 22))
                        .foregroundColor(weatherIconColor(data.weather?.state))
                        .frame(width: 28, height: 28)

                    Text(data.location.title)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.textWhite)
                        .lineLimit(1)
                }

                Spacer()

                if let weather = data.weather {
                    Text("\(Int(weather.temp.rounded()))°")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.textWhite)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.cardOverlay)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }
}
