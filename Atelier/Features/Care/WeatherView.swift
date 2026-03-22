//
//  WeatherView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/02/26.
//

import SwiftUI
import CoreLocation
import WeatherKit

struct WeatherView: View, Equatable{
    let weather: WeatherState?
        
    init(_ weather: WeatherState?) {
        self.weather = weather
    }
    
    var body: some View {
        ZStack {
            self.backgroundView
                .glassEffect(in: .rect)
            
            HStack(alignment: .center) {
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text(weather?.locationName ?? "Placeholder")
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.default)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(weather?.condition.rawValue ?? "Test")
                            .font(.headline)
                            .fontWeight(.light)
                            .fontDesign(.default)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                    }
                    .if(weather == nil, transform: { `view` in
                        `view`
                            .redacted(reason: .placeholder)
                            .shimmer()
                    })
                    
                    Spacer()
                    
                    Text("\(Int(weather?.temperature ?? 0))°")
                        .font(.system(size: 55))
                        .fontWeight(.bold)
                        .fontDesign(.default)
                        .foregroundColor(.primary)
                        .padding(.bottom, -12)
                        .if(weather == nil, transform: { `view` in
                            `view`
                                .redacted(reason: .placeholder)
                                .shimmer()
                        })
                    
                }
                                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Image(systemName: weather?.condition.icon ?? "sun.max.fill")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .symbolRenderingMode(.multicolor)
                    
                    Spacer()
                    
                    Text(weather?.messageWeather ?? "Test Test Test Test Test Test Test ")
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                }
                .if(weather == nil, transform: { `view` in
                    `view`
                        .redacted(reason: .placeholder)
                        .shimmer()
                })
                
            }
            .padding(20)
        }
        .frame(height: 170)
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
