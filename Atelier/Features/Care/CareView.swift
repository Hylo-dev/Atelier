//
//  CareView.swift
//  Atelier
//
//  Created by C4V4H.exe on 18/02/26.
//

import SwiftUI
import CoreLocation
import SwiftData

struct CareView: View {
        
    let title: String
    
    var laundrySessions: [LaundrySession]
    
    
    
    let weatherService = WeatherService()
    
    @Environment(ApplianceManager.self)
    private var manager
    
    @State
    private var weather: WeatherState?
    
    private static let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    var body: some View {
        
        ScrollView {
            LazyVStack(spacing: 20) {
                WeatherView(weather)
                
                LazyVGrid(columns: Self.columns, spacing: 20) {
                    ForEach(laundrySessions, id: \.id) { item in
                        let garmentsWithImage = item.garments.filter {
                            $0.imagePath != nil
                        }
                        
                        MultipleCardView(
                            title: item.bin.displayName,
                            items: garmentsWithImage
                        )
                    }
                }
                .padding(.horizontal, 16)
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
            
            for session in laundrySessions {
                print("\(session.bin) \(session.suggestedProgram) \(session.targetTemperature)")
            }
            
            
            
            Task { @MainActor in
                
                self.weather = try await weatherService.fetchWeather(
                    for: CLLocation(
                        latitude: .zero,
                        longitude: .zero
                    )
                )
                
            }
        }
    }
    
    
    // MARK: - Views
    
}

#Preview {
    
//    @Previewable
//    @Environment(\.modelContext)
//    var context
//    
//    @Previewable
//    @State
//    var manager = ApplianceManager(context)
//    
//    
//    CareView(
//        title: "Care",
//        manager: manager
//    )
}
