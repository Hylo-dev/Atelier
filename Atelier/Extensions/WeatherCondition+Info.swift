//
//  WeatherCondition.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/02/26.
//

import WeatherKit
import SwiftUI


extension WeatherCondition {
    
    var icon: String {
        return switch self {
            case .blizzard:
                "wind.snow"
                
            case .blowingDust:
                "sun.dust.fill"
                
            case .blowingSnow:
                "wind.snow"
                
            case .breezy:
                "wind"
                
            case .clear:
                "sun.max.fill"
                
            case .cloudy:
                "cloud.fill"
                
            case .drizzle:
                "cloud.drizzle.fill"
                
            case .flurries:
                "cloud.snow.fill"
                
            case .foggy:
                "cloud.fog.fill"
                
            case .freezingDrizzle:
                "cloud.sleet.fill"
                
            case .freezingRain:
                "cloud.sleet.fill"
                
            case .frigid:
                "thermometer.snowflake"
                
            case .hail:
                "cloud.hail.fill"
                
            case .haze:
                "sun.haze.fill"
                
            case .heavyRain:
                "cloud.heavyrain.fill"
                
            case .heavySnow:
                "snowflake"
                
            case .hot:
                "thermometer.sun.fill"
                
            case .hurricane:
                "hurricane"
                
            case .isolatedThunderstorms:
                "cloud.bolt.fill"
                
            case .mostlyClear:
                "sun.max.fill"
                
            case .mostlyCloudy:
                "cloud.sun.fill"
                
            case .partlyCloudy:
                "cloud.sun.fill"
                
            case .rain:
                "cloud.rain.fill"
                
            case .scatteredThunderstorms:
                "cloud.bolt.rain.fill"
                
            case .sleet:
                "cloud.sleet.fill"
                
            case .smoky:
                "smoke.fill"
            
            case .snow:
                "cloud.snow.fill"
            
            case .strongStorms:
                "cloud.bolt.rain.fill"
            
            case .sunFlurries:
                "sun.snow.fill"
            
            case .sunShowers:
                "cloud.sun.rain.fill"
            
            case .thunderstorms:
                "cloud.bolt.rain.fill"
            
            case .tropicalStorm:
                "tropicalstorm"
            
            case .windy:
                "wind"
            
            case .wintryMix:
                "cloud.sleet.fill"
                
            @unknown default:
                "questionmark.circle.fill"
        }
    }
    
    var backgroundGradient: LinearGradient {
        
        let gradientColors: [Color] = switch self {
            case .clear, .mostlyClear:
                [Color(red: 0.18, green: 0.50, blue: 0.93), Color(red: 0.35, green: 0.73, blue: 0.98)]
                
            case .hot:
                [Color.orange, Color.red]
                
            case .cloudy, .mostlyCloudy, .partlyCloudy:
                [Color(red: 0.4, green: 0.5, blue: 0.6), Color(red: 0.6, green: 0.7, blue: 0.8)]
                
            case .foggy, .haze, .smoky, .breezy, .windy, .blowingDust:
                [Color(white: 0.4), Color(white: 0.6)]
                
            case .drizzle, .rain, .heavyRain, .sunShowers:
                [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.4, green: 0.5, blue: 0.7)]
                
            case .snow, .heavySnow, .blizzard, .blowingSnow, .flurries, .sunFlurries, .frigid, .sleet, .freezingRain, .freezingDrizzle, .wintryMix, .hail:
                [Color(red: 0.5, green: 0.8, blue: 0.9), Color.white]
                
            case .thunderstorms, .isolatedThunderstorms, .scatteredThunderstorms, .strongStorms:
                [Color(red: 0.1, green: 0.1, blue: 0.3), Color.indigo]
                
            case .hurricane, .tropicalStorm:
                [Color.black, Color(red: 0.3, green: 0.0, blue: 0.0)]
                
            @unknown default:
                [Color.blue, Color.cyan]
        }
        
        return LinearGradient(
            colors: gradientColors,
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
