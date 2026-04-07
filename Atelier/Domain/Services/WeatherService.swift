//
//  WeatherService.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/02/26.
//

import WeatherKit
import CoreLocation


struct WeatherService: WeatherProvider {
    
    func fetchWeather(for location: CLLocation) async throws -> WeatherState {
        
        try? await Task.sleep(for: .seconds(1))
        
        let city = "Torino"
        return WeatherState(
            locationName: city,
            temperature : 20.0,
            condition   : .clear,
            airQuality  : 1
        )
    }
    
}
