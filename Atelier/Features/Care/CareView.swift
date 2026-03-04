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
    
    let title: String
    
    @State
    private var weather: WeatherState?
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                WeatherView(currentWeather: weather)
                
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .title) {
                Text(String(repeating: " ", count: 50))
                    .overlay(alignment: .leading) {
                        Text(self.title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Filter", systemImage: "line.3.horizontal.decrease") {
                    // self.isFilterSheetVisible = true
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") {
                    // self.isAddGarmentSheetVisible = true
                }
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
    CareView(title: "Care")
}
