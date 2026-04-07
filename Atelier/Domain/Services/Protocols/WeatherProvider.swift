//
//  WeatherProvider.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//

import CoreLocation


protocol WeatherProvider {
    func fetchWeather(for location: CLLocation) async throws -> WeatherState
}
