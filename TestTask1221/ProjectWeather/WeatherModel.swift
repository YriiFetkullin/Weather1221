//
//  WeatherModel.swift
//  TestTask1221
//
//  Created by Юрий Феткуллин on 25.05.2025.
//

import Foundation

struct WeatherResponse: Codable {
    let forecast: Forecast
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable {
    var id: String { date }
    let date: String
    let day: Day
}

struct Day: Codable {
    let avgtemp_c: Double?
    let maxwind_kph: Double?
    let avghumidity: Double?
    let condition: Condition
}

struct Condition: Codable {
    let text: String?
    let icon: String
}


