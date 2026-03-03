//
//  CareView.swift
//  Atelier
//
//  Created by C4V4H.exe on 18/02/26.
//

import SwiftUI
import CoreLocation

struct CareView: View {
    
    let service = WeatherService()
    
    @State
    private var weather: WeatherState?
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                
                WeatherView(currentWeather: weather)
                
                
            }
            
        }
        .onAppear {
            Task { @MainActor in
                
                self.weather = try await service.fetchWeather(
                    for: CLLocation(
                        latitude: .zero,
                        longitude: .zero
                    )
                )
                
            }
        }
        
    }
}

#Preview {
    CareView()
}
