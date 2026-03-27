//
//  CareView.swift
//  Atelier
//
//  Created by C4V4H.exe on 18/02/26.
//

import SwiftUI
import CoreLocation
import SwiftData
internal import Combine

struct CareView: View {
    
    @Environment(\.scenePhase)
    private var scenePhase
    
    
    
    @Query( // TODO: This is for testing, completed laundry appears on history section or filter toggle
        // filter: #Predicate<LaundrySession> { !$0.isCompleted },
        sort  : \LaundrySession.dateCreated,
        order : .forward
    )
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
                        isEnabled  : laundryState.isPagesEnabled
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
            Task { @MainActor in
                self.weather = try await weatherService.fetchWeather(
                    for: CLLocation(
                        latitude: .zero,
                        longitude: .zero
                    )
                )
                
            }
        }
        .onChange(of: laundrySessions, initial: true) {
            updateBins()
            updateFilteredGarments()
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
    
}

fileprivate struct ItemCareView: View {
    
    let item    : LaundrySession
    let manager : ApplianceManager
    let garments: [Garment]
    
    @State
    private var timeRemaining: TimeInterval = 0
    
    let timer = Timer.publish(
        every: 1, on: .main, in: .common
    ).autoconnect()
    
        
    init(
        item    : LaundrySession,
        manager : ApplianceManager,
        garments: [Garment]
    ) {
        self.item     = item
        self.manager  = manager
        self.garments = garments
        
    }
    
    var body: some View {
        
        // TODO: When item status is `completed` change card UI
        NavigationLink(value: item) {
            MultipleCardView(
                title      : "\(item.targetTemperature)° \(item.suggestedProgram.displayName)",
                subheadline: item.subheadline,
                items      : garments
            )
            .equatable()
            .id(item.id)
        }
        .buttonStyle(.plain)
        .contextMenu { actionButton }
        .onReceive(timer) { _ in
            guard item.status == .washing else { return }
            
            updateTimeRemaining()
            if timeRemaining <= 0 {
                timer.upstream.connect().cancel()
                manager.finishWashing(item)
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
                        Label("Start Wash", systemImage: "play.fill")
                    }
                    
                    
                case .washing:
                    
                    Label(
                        formatDuration(timeRemaining),
                        systemImage: "timer"
                    )
                    .onAppear {
                        if timeRemaining == 0 {
                            updateTimeRemaining()
                        }
                    }
                    
                    Button {
                        manager.pauseWashing(item)
                    } label: {
                        Label("Pause Wash", systemImage: "pause.fill")
                    }
                    
                    
                    Divider()
                    
                    
                    Button {
                        manager.finishWashing(item)
                        
                    } label: {
                        Label("Finish Wash", systemImage: "checkmark.circle")
                    }
                    
                    Button(role: .destructive) {
                        manager.cancelWashing(item)
                    } label: {
                        Label("Cancel Wash", systemImage: "xmark.circle")
                    }
                    
                    
                case .clean:
                    Button {
                        manager.startDrying(item)
                    } label: {
                        Label("Start Drying", systemImage: "sun.max.fill")
                    }
                    
                    
                case .paused:
                    Label(
                        formatDuration(item.remainingTime ?? 0),
                        systemImage: "pause.circle"
                    )
                    
                    Button {
                        manager.resumeWashing(item)
                    } label: {
                        Label("Resume Wash", systemImage: "play.fill")
                    }
                    
                    Divider()
                    
                    Button {
                        manager.finishWashing(item)
                    } label: {
                        Label("Finish Wash", systemImage: "checkmark.circle")
                    }
                    
                    Button(role: .destructive) {
                        manager.cancelWashing(item)
                    } label: {
                        Label("Cancel Wash", systemImage: "xmark.circle")
                    }
                
                    
                case .drying:
                    Button {
                        manager.markAsComplete(item)
                    } label: {
                        Label("Mark as Done", systemImage: "checkmark.seal.fill")
                    }
                    
                    Button {
                        manager.cancelDrying(item)
                    } label: {
                        Label("Cancel Drying", systemImage: "xmark.circle")
                    }
                    
                    
                default:
                    EmptyView()
            }
        }
    }
    
    private func updateTimeRemaining() {
        guard let endDate = item.completationDate else {
            timeRemaining = 0
            return
        }
        
        let remaining = endDate.timeIntervalSinceNow
        timeRemaining = max(0, remaining)
    }
    
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let interval = Int(seconds)
        let mins = (interval % 3600) / 60
        let secs = interval % 60
        
        return String(format: "%02d:%02d", mins, secs)
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
