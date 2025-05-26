//
//  WeatherView.swift
//  TestTask1221
//
//  Created by Юрий Феткуллин on 25.05.2025.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var city: String = "Москва"
    @State private var inputError: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        TextField("Введите город", text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .onSubmit {
                                loadWeatherIfValid()
                            }

                        Button(action: {
                            loadWeatherIfValid()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .padding(.trailing)
                        }
                    }
                    .padding(.top)

                    if let inputError = inputError {
                        Text(inputError)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.bottom, 4)
                    }

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Загрузка...")
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        Text("Ошибка: \(error)")
                            .foregroundColor(.red)
                        Spacer()
                    } else {
                        List(viewModel.forecast) { day in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(day.date)
                                        .font(.headline)
                                    Text(day.day.condition.text)
                                        .font(.subheadline)
                                    Text("Температура: \(day.day.temp_c, specifier: "%.1f")°C")
                                    Text("Ветер: \(day.day.maxwind_kph, specifier: "%.1f") км/ч")
                                    Text("Влажность: \(day.day.avghumidity, specifier: "%.0f")%")
                                }
                                Spacer()
                                AsyncImage(url: URL(string: "https:\(day.day.condition.icon)")) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .navigationTitle("Прогноз погоды")
            }
        }
        .onAppear {
            viewModel.loadWeather(for: city)
        }
    }

    private func loadWeatherIfValid() {
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCity.isEmpty else {
            inputError = "Пожалуйста, введите название города."
            return
        }

        inputError = nil
        viewModel.loadWeather(for: trimmedCity)
    }
}

#Preview {
    WeatherView()
}

