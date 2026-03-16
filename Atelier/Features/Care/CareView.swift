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
    
    @Environment(\.scenePhase)
    private var scenePhase
    
    
    
    @Query(sort : \LaundrySession.dateCreated, order: .forward)
    private var laundrySessions: [LaundrySession]
    
    
    
    // MARK: - Struct attributes
        
    let title: String
        
    @Bindable
    var laundryState: TabFilterState
    
    
    
    // MARK: - private managers
    
    let weatherService = WeatherService()
    
    @Environment(ApplianceManager.self)
    private var manager
        
    @State
    private var weather: WeatherState?
    
    
    
    // MARK: - Private state variables
    
    @State
    private var groupedBins: [String: [LaundrySession]] = [:]
    
    @State
    private var garmentsWithImage: [UUID: [Garment]] = [:]
        
    @State
    private var isWidgetVisible: Bool = true
    
    private static let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    
    
    var body: some View {
        
        Group {
            
            if self.laundrySessions.isEmpty {
                ContentUnavailableView(
                    "Closet Empty",
                    systemImage: "hanger",
                    description: Text("Time to fill this closet up")
                )
                .containerRelativeFrame(.vertical)
                
            } else {
                
                VStack(spacing: 20) {
                    if isWidgetVisible {
                        WeatherView(weather)
                            .equatable()
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    LiquidPagingView(
                        selection  : $laundryState.selection,
                        onProgressChange: { newVal in
                            if laundryState.progress != newVal {
                                laundryState.progress = newVal
                            }
                        },
                        items      : laundryState.items,
                        isEnabled  : laundryState.isVisible
                    ) { binType in
                        
                        gridView(binType)
                    }
                    .ignoresSafeArea(.container, edges: .top)
                }
                .animation(.easeInOut(duration: 0.3), value: isWidgetVisible)
            }
            
        }.toolbar {
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
        .navigationDestination(for: LaundrySession.self) { selectedItem in
            InfoCareView(selectedItem)
        }
        .onAppear {
            updateBins()
            updateFilteredGarments()
            
            
            
            Task { @MainActor in
                
                self.weather = try await weatherService.fetchWeather(
                    for: CLLocation(
                        latitude: .zero,
                        longitude: .zero
                    )
                )
                
            }
        }
        .onChange(of: laundrySessions) {
            updateBins()
            updateFilteredGarments()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkPendingCancellations()
            }
        }
    }
    
    
    // MARK: - Views
    
    
    
    @ViewBuilder
    private func gridView(_ type: String) -> some View {
        let items = groupedBins[type] ?? []
        let hasEnoughItems = items.count >= 4
        
        ScrollView {
            LazyVGrid(columns: Self.columns, spacing: 20) {
                ForEach(groupedBins[type] ?? [], id: \.id) { item in
                    
                    ItemCareView(
                        item    : item,
                        manager : manager,
                        garments: garmentsWithImage[item.id] ?? []
                    )
                }
            }
            .padding(.horizontal, 16)
            
        }
        .scrollIndicators(.hidden)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { oldValue, newValue in
            guard hasEnoughItems else {
                if !isWidgetVisible { isWidgetVisible = true }
                return
            }
            
            let isScrollingDown = newValue > oldValue
            let isScrollingUp = newValue < oldValue
            
            if isScrollingDown && newValue > 20 {
                if isWidgetVisible {
                    isWidgetVisible = false
                }
                
            } else if isScrollingUp {
                if !isWidgetVisible {
                    isWidgetVisible = true
                }
            }
        }
    }
    
    
    
    
    // MARK: - Handlers
    
    
    @inline(__always)
    private func updateFilteredGarments() {
        var newGrouped: [String: [LaundrySession]] = [:]
        newGrouped["All"] = laundrySessions
        
        let groupedByCategory = Dictionary(
            grouping: self.laundrySessions,
            by: { $0.bin.displayName }
        )
        
        for (category, items) in groupedByCategory {
            newGrouped[category] = items
        }
        
        self.groupedBins = newGrouped
        
        var newGarmentsWithImage: [UUID: [Garment]] = [:]
        for session in self.laundrySessions {
            newGarmentsWithImage[session.id] = session.garments.filter {
                $0.imagePath != nil
            }
        }
        
        self.garmentsWithImage = newGarmentsWithImage
    }
    
    
    
    @inline(__always)
    private func updateBins() {
        let uniqueCategories = Set(laundrySessions.lazy.map {
            $0.bin.displayName
        })
        let newCategories = ["All"] + uniqueCategories.sorted()
        
        if laundryState.items != newCategories {
            print("Diff found: Updating bins pointer")
            self.laundryState.items = newCategories
            
        } else {
            print("No changes in bins, skipping update to save cycles")
        }
    }
    
    
    
    private func checkPendingCancellations() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.hylo.team.Atelier") else { return }
        
        if let canceledIDString = sharedDefaults.string(forKey: "canceledSessionID") {
            if let sessionToCancel = laundrySessions.first(
                where: { $0.id.uuidString == canceledIDString }
            ) {
                manager.cancelWashing(sessionToCancel)
                print("Cancel session with success")
            }
            
            sharedDefaults.removeObject(forKey: "canceledSessionID")
        }
    }
}

fileprivate struct ItemCareView: View {
    
    let item    : LaundrySession
    let manager : ApplianceManager
    let garments: [Garment]
    
    var body: some View {
        
        NavigationLink(value: item) {
            MultipleCardView(
                title: "\(item.targetTemperature)° \(item.suggestedProgram.displayName)",
                items: garments
            )
            .equatable()
            .id(item.id)
        }
        .buttonStyle(.plain)
        .contextMenu {
            actionButton
        }
        .onAppear {
            if item.status == .washing {
                manager.resumeWashing(item)
            }
        }
    }
    
    private var actionButton: some View {
        Group {
            switch item.status {
                case .planned:
                    Button {
                        manager.startWashing(item)
                    } label: {
                        Label("Start Washing", systemImage: "washer.fill")
                    }
                    
                case .washing:
                    Button {
                        manager.cancelWashing(item)
                    } label: {
                        Label("Cancel Washing", systemImage: "stop.fill")
                    }
                    
                case .completed, .drying:
                    Button {
                        manager.markAsClean(item)
                    } label: {
                        Label("Set clean all", systemImage: "checkmark.seal.fill")
                    }
                    .tint(.green)
                    
                default:
                    EmptyView()
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
