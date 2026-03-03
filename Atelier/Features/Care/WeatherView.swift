//
//  WeatherView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/02/26.
//

import SwiftUI
import CoreLocation
import WeatherKit

struct WeatherView: View {
    let currentWeather: WeatherState?
    
    var body: some View {
        ZStack {
            self.backgroundView
                .glassEffect(in: .rect)
            
            if let weather = self.currentWeather {
                HStack(alignment: .center) {
                    
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(weather.locationName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        
                        Spacer()
                        
                        Text(weather.messageWeather)
                            .font(.subheadline)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(.white.opacity(0.9))
                        
                    }
                    
                    Spacer()
                    
                    
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: weather.condition.icon)
                            .resizable()
                            .scaledToFit()
                            .font(.system(size: 70))
                            .symbolRenderingMode(.multicolor)
                        
                        Text("\(Int(weather.temperature))°")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                            .offset(x: -40, y: -10)
                    }
                    
                    
                }
                .padding(24)
                
                
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.white)
                    
                    Text("Recupero meteo...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if let weather = self.currentWeather {
            weather.condition.backgroundGradient
            
        } else {
            Color.gray.opacity(0.3)
        }
    }
}


#Preview {
    @Previewable
    @State
    var weather: WeatherState?
    
    let service = WeatherService()
    
    WeatherView(currentWeather: weather)
        .onAppear {
            Task { @MainActor in
                weather = try await service.fetchWeather(
                    for: CLLocation(
                        latitude : .zero,
                        longitude: .zero
                    )
                )
                
            }
        }
}
