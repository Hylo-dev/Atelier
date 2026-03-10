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
    let weather: WeatherState?
    
    init(_ weather: WeatherState?) {
        self.weather = weather
    }
    
    var body: some View {
        ZStack {
            self.backgroundView
                .glassEffect(in: .rect)
            
            HStack(alignment: .center) {
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: weather?.condition.icon ?? "sun.max.fill")
                            .font(.title)
                            .fontWeight(.bold)
                            .symbolRenderingMode(.multicolor)
                        
                        Text("\(Int(weather?.temperature ?? 00))°")
                            .font(.title)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                    }
                    .if(weather == nil, transform: { `view` in
                        `view`
                            .redacted(reason: .placeholder)
                            .shimmer()
                    })
                    
                    Spacer()
                    
                    Text(weather?.messageWeather ?? "Test Test Test Test Test Test Test ")
                        .font(.subheadline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .foregroundColor(.primary)
                        .if(weather == nil, transform: { `view` in
                            `view`
                                .redacted(reason: .placeholder)
                                .shimmer()
                        })
                    
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(weather?.locationName ?? "Placeholder")
                        .font(.headline)
                        .fontWeight(.bold)
                        .fontDesign(.default)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(weather?.condition.rawValue ?? "Test")
                        .font(.subheadline)
                        .fontWeight(.light)
                        .fontDesign(.default)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .if(weather == nil, transform: { `view` in
                    `view`
                        .redacted(reason: .placeholder)
                        .shimmer()
                })
            }
            .padding(24)
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .padding(.horizontal)
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if let weather = self.weather {
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
    
    WeatherView(weather)
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
