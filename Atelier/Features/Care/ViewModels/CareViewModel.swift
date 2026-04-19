//
//  CareViewModel.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/04/2026.
//

import Observation
import SwiftUI

@Observable
final class CareViewModel {
    
    var alertManager: AlertManager
    var weatherService: WeatherProvider
    var weather: WeatherState?
    
    var editableItem: LaundrySession?
    
    var selectedItem: LaundrySession?
    
    var processedSession: Processed<LaundrySession>
    
    var isWidgetVisible: Bool
    
    private var processingTask: Task<Void, Never>? = nil
    
    init(weatherService: WeatherProvider = WeatherService()) {
        
        self.alertManager     = AlertManager()
        self.weatherService   = weatherService
        self.weather          = nil
        self.editableItem     = nil
        self.selectedItem     = nil
        self.processedSession = Processed()
        self.isWidgetVisible  = true
        
    }
    
    func handleSessionChange(
        _ newGarments: [LaundrySession],
        manager      : ApplianceManager
    ) {
        processingTask?.cancel()
        
        processingTask = Task {
            let result = await manager.process(newGarments)
            
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation(.snappy) {
                        processedSession = result
                    }
                }
            }
        }
    }
    
}
