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
    
    @Environment(ApplianceManager.self)
    private var manager
    
            
    private let title: String
        
    private var careState: TabFilterService
    
    @State
    private var careViewModel = CareViewModel()
    
    @State
    private var filterManager = FilterManager<FilterCareConfig>()

    
    init(
        title       : String,
        laundryState: TabFilterService
    ) {
        self.title     = title
        self.careState = laundryState
    }
    
    var body: some View {
        
        bodyModifiers(
            CareListContent(
                title        : title,
                filterManager: filterManager,
                careViewModel: careViewModel,
                careState    : careState
            )
            .animation(
                .snappy,
                value: filterManager.predicate.description
            )
        )
        .onAppear {
            Task { @MainActor in
                do {
                    careViewModel.weather = try await careViewModel.weatherService.fetchWeather(
                        for: CLLocation(latitude: .zero, longitude: .zero)
                    )
                    
                } catch {
                    careViewModel.alertManager.title   = "Weather Error"
                    careViewModel.alertManager.message = "Impossible update weather"
                    careViewModel.alertManager.isPresent = true
                }
                
            }
        }
        //            .onChange(of: laundrySessions, initial: true) {
        //                updateBins()
        //                updateFilteredGarments()
        //            }
        .onChange(of: careViewModel.processedSession) { _, newValue in
            if careState.items != newValue.tag {
                careState.items = newValue.tag
            }
        }
        .onChange(of: filterManager.isFiltering) { _, newValue in
            careState.hiddenSectionBar = newValue
        }
        .onChange(of: careViewModel.selectedItem) { _, newValue in
            if newValue == nil {
                withAnimation { careState.hiddenSectionBar = false }
            }
        }
    }
    
    private func bodyModifiers(_ view: some View) -> some View {
        view
            .navigationDestination(item: $careViewModel.selectedItem) { selectedItem in
                InfoCareView(selectedItem)
            }
            .alert(
                careViewModel.alertManager.title,
                isPresented: $careViewModel.alertManager.isPresent
            ) {
                
            } message: {
                Text(careViewModel.alertManager.message)
            }
        
    }
    
    
    // MARK: - Handlers
    
    
//    @inline(__always)
//    private func updateFilteredGarments() {
//        var newGrouped: [String: [LaundrySession]] = [:]
//        newGrouped["All"] = laundrySessions
//        
//        let groupedByCategory = Dictionary(
//            grouping: self.laundrySessions,
//            by: { $0.bin.displayName }
//        )
//        
//        for (category, items) in groupedByCategory {
//            newGrouped[category] = items
//        }
//        
//        self.groupedBins = newGrouped
//        
//        var newGarmentsWithImage: [UUID: [Garment]] = [:]
//        for session in self.laundrySessions {
//            newGarmentsWithImage[session.id] = session.garments.filter {
//                $0.imagePath != nil
//            }
//        }
//        
//        self.garmentsWithImage = newGarmentsWithImage
//    }
//    
//    
//    
//    @inline(__always)
//    private func updateBins() {
//        let uniqueCategories = Set(laundrySessions.lazy.map {
//            $0.bin.displayName
//        })
//        let newCategories = ["All"] + uniqueCategories.sorted()
//        
//        if laundryState.items != newCategories {
//            print("Diff found: Updating bins pointer")
//            self.laundryState.items = newCategories
//            
//        } else {
//            print("No changes in bins, skipping update to save cycles")
//        }
//    }
    
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
