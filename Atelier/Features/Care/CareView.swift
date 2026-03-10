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
    
    
    
    var body: some View {
        
        ScrollView {
            LazyVStack {
                WeatherView(weather)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 20)]) {
                    ForEach(laundrySessions, id: \.id) { item in
                        
                        ZStack(alignment: .bottomLeading) {
                            
                            Color.secondary.opacity(0.15)
                                .aspectRatio(1, contentMode: .fit)
                                .overlay {
                                    
                                    
                                    //                                if let path = self.imagePath {
                                    //                                    CachedImageView(imagePath: path)
                                    //
                                    //                                } else {
                                    Image(systemName: "hanger")
                                        .font(.largeTitle)
                                        .foregroundStyle(.secondary.opacity(0.4))
                                    //                                }
                                }
                                .clipShape(Rectangle())
                            
                            //                        if self.imagePath != nil {
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .black.opacity(0.6), location: 0.5),
                                    .init(color: .black.opacity(0.8), location: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 80)
                            //                        }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.bin.rawValue)
                                    .font(.headline)
                                    .fontDesign(.rounded)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .foregroundStyle(.primary)
                                
                                //                            if let subhead = self.subheadline {
                                //                                Text(subhead)
                                //                                    .font(.caption)
                                //                                    .fontDesign(.rounded)
                                //                                    .fontWeight(.regular)
                                //                                    .foregroundStyle(.secondary)
                                //                                    .lineLimit(1)
                                //                            }
                            }
                            .padding(12)
                            .frame(
                                maxWidth : .infinity,
                                alignment: .leading
                            )
                            .background(.clear)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                    }
                }
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
