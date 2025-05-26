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

    private let apiKey = "e2b39d950ab14fca93d130639252505"

    func loadWeather(for city: String) {
        isLoading = true
        errorMessage = nil
        forecast = []

        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(city)&days=5&aqi=no&alerts=no"

        guard let url = URL(string: urlString) else {
            errorMessage = "Неверный URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Ошибка сети: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Некорректный ответ от сервера"
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Ошибка \(httpResponse.statusCode): \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "Данные не получены"
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    self.forecast = decoded.forecast.forecastday
                } catch {
                    self.errorMessage = "Ошибка при разборе данных: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

