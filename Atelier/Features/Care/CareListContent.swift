//
//  CareListContent.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/04/2026.
//

import SwiftUI
import SwiftData

struct CareListContent: View {
    
    @Environment(ApplianceManager.self)
    private var manager
    
    private let title: String
    
    
    @Query
    private var laundrySessions: [LaundrySession]
    
    
    @Bindable
    private var filterManager: FilterManager<FilterCareConfig>
    
    @Bindable
    private var careViewModel: CareViewModel
    
    @Bindable
    var careState: TabFilterService
    
    init(
        title        : String,
        filterManager: FilterManager<FilterCareConfig>,
        careViewModel: CareViewModel,
        careState    : TabFilterService
    ) {
        self.title         = title
        
        self.filterManager = filterManager
        self.careViewModel = careViewModel
        self.careState     = careState
        
        _laundrySessions = Query(
            filter: filterManager.predicate,
            sort  : \LaundrySession.dateCreated,
            order : .reverse
        )
    }
    
    var body: some View {
        
        Group {
            if laundrySessions.isEmpty {
                emptyView
                
            } else {
                pagingView
            }
        }
        .toolbar {
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
        .onChange(of: laundrySessions, initial: true) { _, newGarments in
            careViewModel.handleSessionChange(
                newGarments,
                manager: manager
            )
        }
    }
    
    
    private var emptyView: some View {
        
        ContentUnavailableView(
            "No Active Sessions",
            systemImage: "washer.fill",
            description: Text("Start a wash to see progress and timers.")
        )
        .containerRelativeFrame(.vertical)
    }
    
    
    private var pagingView: some View {
        
        VStack {
            if careViewModel.isWidgetVisible {
                WeatherView(careViewModel.weather)
                    .equatable()
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                    )
            }
            
            LiquidPagingView(
                selection  : $careState.selection,
                onProgressChange: { newVal in
                    if careState.progress != newVal {
                        careState.progress = newVal
                    }
                },
                items    : careState.items,
                isEnabled: careState.isPagesEnabled
                
            ) { binType in
                
                let visibles = careViewModel.processedSession.grouped[binType] ?? []
                let hasEnoughItems = visibles.count >= 4
                
                VerticalScrollGridView(
                    items : visibles,
                    insets: 20
                ) { item in
                    
                    CareContextCardView(
                        item     : item,
                        manager  : manager,
                        viewModel: careViewModel
                    )
                    .id(item.persistentModelID)
                    
                }
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y
                } action: { oldValue, newValue in
                    guard hasEnoughItems else {
                        if !careViewModel.isWidgetVisible { careViewModel.isWidgetVisible = true }
                        return
                    }
                    
                    let isScrollingDown = newValue > oldValue
                    let isScrollingUp = newValue < oldValue
                    
                    if isScrollingDown && newValue > 20 {
                        if careViewModel.isWidgetVisible {
                            careViewModel.isWidgetVisible = false
                        }
                        
                    } else if isScrollingUp {
                        if !careViewModel.isWidgetVisible {
                            careViewModel.isWidgetVisible = true
                        }
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .top)
        }
        .animation(
            .easeInOut(duration: 0.3),
            value: careViewModel.isWidgetVisible
        )
    }
}
