//
//  WeatherViewModel.swift
//  TestTask1221
//
//  Created by Юрий Феткуллин on 25.05.2025.
//

import Foundation

class WeatherViewModel: ObservableObject {
    @Published var forecast: [ForecastDay] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var city: String = "Москва"
    @Published var inputError: String?

    private let apiKey = "9722bbcc7f70467d92d121842252605"

    private let conditionTranslations: [String: String] = [
        "Sunny": "Солнечно",
        "Partly Cloudy": "Переменная облачность",
        "Cloudy": "Облачно",
        "Moderate rain": "Умеренный дождь",
        "Heavy rain": "Сильный дождь",
        "Patchy rain nearby": "Местами дождь",
        "Snow": "Снег",
        "Thunderstorm": "Гроза"
    ]

    @MainActor
    func loadWeather(for city: String) async {
        isLoading = true
        errorMessage = nil
        forecast = []

        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(trimmedCity)&days=5&aqi=no&alerts=no"

        guard let url = URL(string: urlString) else {
            errorMessage = "Неверный URL"
            isLoading = false
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                errorMessage = "Ошибка сервера"
                return
            }

            let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
            forecast = decoded.forecast.forecastday
        } catch {
            errorMessage = "Ошибка: \(error.localizedDescription)"
        }
        isLoading = false
    }

    @MainActor
    func loadWeatherIfValid() {
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCity.isEmpty else {
            inputError = "Пожалуйста, введите название города."
            return
        }
        inputError = nil

        Task {
            await loadWeather(for: trimmedCity)
        }
    }
}

extension WeatherViewModel {
    func dateText(for day: ForecastDay) -> String {
        return day.date
    }

    func conditionText(for day: ForecastDay) -> String {
        let original = day.day.condition.text
        return conditionTranslations[original ?? ""] ?? original ?? ""
    }

    func temperatureText(for day: ForecastDay) -> String {
        let value = day.day.avgtemp_c ?? 0.0
        return String(format: "Температура: %.1f°C", value)
    }

    func windText(for day: ForecastDay) -> String {
        let value = day.day.maxwind_kph ?? 0.0
        return String(format: "Ветер: %.1f км/ч", value)
    }

    func humidityText(for day: ForecastDay) -> String {
        let value = day.day.avghumidity ?? 0.0
        return String(format: "Влажность: %.0f%%", value)
    }

    func iconURL(for day: ForecastDay) -> URL? {
        URL(string: "https:\(day.day.condition.icon)")
    }
}
