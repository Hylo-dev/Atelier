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
    
    @Environment(ApplianceManager.self)
    private var manager
    
    
    @Query( // TODO: This is for testing, completed laundry appears on history section or filter toggle
        // filter: #Predicate<LaundrySession> { !$0.isCompleted },
        sort  : \LaundrySession.dateCreated,
        order : .forward
    )
    private var laundrySessions: [LaundrySession]
    
    
    
    @State
    private var alertManager: AlertManager
    
    
    // MARK: - Struct attributes
        
    let title: String
        
    @Bindable
    var laundryState: TabFilterService
    
    
    // MARK: - private managers
    
    var weatherService: WeatherProvider
        
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
    
    
    init(
        title         : String,
        laundryState  : TabFilterService,
        weatherService: WeatherProvider = WeatherService(),
        alertManager  : AlertManager   = AlertManager()
    ) {
        self.title          = title
        self.laundryState   = laundryState
        self.weatherService = weatherService
        self._alertManager  = State(initialValue: alertManager)
    }
    
    
    var body: some View {
        
        Group {
            
            if self.laundrySessions.isEmpty {
                ContentUnavailableView(
                    "No Active Sessions",
                    systemImage: "washer.fill",
                    description: Text("Start a wash to see progress and timers.")
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
                Text(String(repeating: " ", count: 150))
                    .overlay(alignment: .leading) {
                        Text(self.title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
            }
            
            if !laundrySessions.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Filter", systemImage: "line.3.horizontal.decrease") {
                        // self.isFilterSheetVisible = true
                    }
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
                do {
                    self.weather = try await weatherService.fetchWeather(
                        for: CLLocation(latitude: .zero, longitude: .zero)
                    )
                    
                } catch {
                    alertManager.title   = "Weather Error"
                    alertManager.message = "Impossible update weather"
                    alertManager.isPresent = true
                }
                
            }
        }
        .onChange(of: laundrySessions, initial: true) {
            updateBins()
            updateFilteredGarments()
        }
        .alert(
            alertManager.title,
            isPresented: $alertManager.isPresent
        ) {
    
        } message: {
            Text(alertManager.message)
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
                    
                    ) { title, message in
                        alertManager.title     = title
                        alertManager.message   = message
                        alertManager.isPresent = true
                    }
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
    let manager : LaundrySessionManaging
    let garments: [Garment]
    let onError : (String, String) -> Void
    
    @State
    private var timeRemaining: TimeInterval = 0
        
    init(
        item    : LaundrySession,
        manager : LaundrySessionManaging,
        garments: [Garment],
        onError : @escaping (String, String) -> Void
    ) {
        self.item     = item
        self.manager  = manager
        self.garments = garments
        self.onError  = onError
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
        .onReceive(manager.timerPulse) { _ in
            guard item.status == .washing else { return }
            
            updateTimeRemaining()
            if timeRemaining <= 0 {
                handleAutoFinish()
            }
        }
        .onAppear(perform: updateTimeRemaining)
        .onChange(of: item.status) { _, _ in
            updateTimeRemaining()
        }
    }
    
    private func handleAutoFinish() {
        do {
            try manager.finishWashing(item)
        } catch {
            onError("Finish Washing", error.localizedDescription)
        }
    }
    
    private var actionButton: some View {
        Group {
            switch item.status {
                case .planned:
                    Button {
                        do {
                            try manager.startWashing(item)
                        } catch {
                            onError(
                                "Start Washing",
                                error.localizedDescription
                            )
                        }
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
                        do {
                            try manager.pauseWashing(item)
                        } catch {
                            onError(
                                "Pause Washing",
                                error.localizedDescription
                            )
                        }
                    } label: {
                        Label("Pause Wash", systemImage: "pause.fill")
                    }
                    
                    
                    Divider()
                    
                    
                    Button {
                        do {
                            try manager.finishWashing(item)
                        } catch {
                            onError(
                                "Finish Washing",
                                error.localizedDescription
                            )
                        }
                        
                    } label: {
                        Label("Finish Wash", systemImage: "checkmark.circle")
                    }
                    
                    Button(role: .destructive) {
                        do {
                            try manager.cancelWashing(item)
                        } catch {
                            onError(
                                "Cancel Washing",
                                error.localizedDescription
                            )
                        }
                        
                    } label: {
                        Label("Cancel Wash", systemImage: "xmark.circle")
                    }
                    
                    
                case .clean:
                    Button {
                        do {
                           try manager.startDrying(item)
                        } catch {
                            onError(
                                "Start Washing",
                                error.localizedDescription
                            )
                        }
                        
                    } label: {
                        Label("Start Drying", systemImage: "sun.max.fill")
                    }
                    
                    
                case .paused:
                    Label(
                        formatDuration(item.remainingTime ?? 0),
                        systemImage: "pause.circle"
                    )
                    
                    Button {
                        do {
                            try manager.resumeWashing(item)
                        } catch {
                            onError(
                                "Resume Washing",
                                error.localizedDescription
                            )
                        }
                        
                    } label: {
                        Label("Resume Wash", systemImage: "play.fill")
                    }
                    
                    Divider()
                    
                    Button {
                        do {
                            try manager.finishWashing(item)
                        } catch {
                            onError(
                                "Finish Washing",
                                error.localizedDescription
                            )
                        }
                        
                    } label: {
                        Label("Finish Wash", systemImage: "checkmark.circle")
                    }
                    
                    Button(role: .destructive) {
                        do {
                           try manager.cancelWashing(item)
                        } catch {
                            onError(
                                "Cancel Washing",
                                error.localizedDescription
                            )
                        }
                        
                    } label: {
                        Label("Cancel Wash", systemImage: "xmark.circle")
                    }
                
                    
                case .drying:
                    Button {
                        do {
                           try manager.markAsComplete(item)
                        } catch {
                            onError(
                                "Mark Complete",
                                error.localizedDescription
                            )
                        }
                        
                    } label: {
                        Label("Mark as Done", systemImage: "checkmark.seal.fill")
                    }
                    
                    Button {
                        do {
                           try manager.cancelDrying(item)
                        } catch {
                            onError(
                                "Cancel Drying",
                                error.localizedDescription
                            )
                        }
                        
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
