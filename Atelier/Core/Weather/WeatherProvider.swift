//
//  WeatherProvider.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/02/26.
//

import CoreLocation
import WeatherKit

struct WeatherState: Equatable {
    let locationName : String
    let temperature  : Double
    let condition    : WeatherCondition
    let airQuality   : Int
    
    var messageWeather: String {
        
        let validWeathers: Set<WeatherCondition> = [
            .clear, .mostlyClear, .partlyCloudy, .mostlyCloudy, .cloudy,
            .hot, .breezy, .windy
        ]
        
        let isValid    = validWeathers.contains(self.condition)
        let isAirClean = self.airQuality < 3
        
        return if isValid && isAirClean {
            "Dry outdoors\nThe weather is fine"
            
        } else if isValid && !isAirClean {
            "Use Dry Machine\nPoor air quality"
            
        } else {
            "Use Dry Machine\nWeather not suitable"
        }
        
    }
}

protocol WeatherProvider {
    func fetchWeather(for location: CLLocation) async throws -> WeatherState
    
    
}
