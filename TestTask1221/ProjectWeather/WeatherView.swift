//
//  WeatherView.swift
//  TestTask1221
//
//  Created by Юрий Феткуллин on 25.05.2025.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        TextField("Введите город", text: $viewModel.city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .onSubmit {
                                viewModel.loadWeatherIfValid()
                            }

                        Button(action: {
                            viewModel.loadWeatherIfValid()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .padding(.trailing)
                        }
                    }
                    .padding(.top)

                    if let inputError = viewModel.inputError {
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
                                    Text(viewModel.dateText(for: day))
                                        .font(.headline)
                                    Text(viewModel.conditionText(for: day))
                                        .font(.subheadline)
                                    Text(viewModel.temperatureText(for: day))
                                    Text(viewModel.windText(for: day))
                                    Text(viewModel.humidityText(for: day))
                                }
                                Spacer()
                                if let url = viewModel.iconURL(for: day) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 50, height: 50)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .navigationTitle("Прогноз погоды")
            }
        }
        .onAppear {
            Task {
                await viewModel.loadWeather(for: viewModel.city)
            }
        }
    }
}

#Preview {
    WeatherView()
}

