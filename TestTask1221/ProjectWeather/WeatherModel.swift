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
    let avgTemp: Double?
    let maxWind: Double?
    let avgHumidity: Double?
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case avgTemp = "avgtemp_c"
        case maxWind = "maxwind_kph"
        case avgHumidity = "avghumidity"
        case condition
    }
}

struct Condition: Codable {
    let text: String?
    let icon: String
}


