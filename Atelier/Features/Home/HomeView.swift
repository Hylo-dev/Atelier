//
//  HomeView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    
    // MARK: - Screen values
    
    @Environment(\.horizontalSizeClass)
    private var sizeClass
    
    @State
    private var selectedTab: AppTab? = .wardrobe
    
    @State
    private var manager = CaptureManager()
    
    
    // MARK: - Categories app bar state
    
    @State
    private var categoryState: TabFilterState = TabFilterState()
    
    @State
    private var selection : String?  = "All"
    
    @State
    private var progress : CGFloat  = .zero
    
    
    // MARK: - Season app bar state
    
    @State
    private var seasonState: TabFilterState = TabFilterState()
    
    
    var body: some View {
//        let _ = Self._printChanges()
        
        if sizeClass == .regular {
            self.sidebarLayout
            
        } else { self.tabLayout }
    }
    
    private var tabLayout: some View {
        TabView(selection: self.$selectedTab) {
            
            ForEach(AppTab.allCases.filter(\.isAvailable), id: \.id) { tab in
                
                Tab(
                    tab.title,
                    systemImage: tab.icon,
                    value      : tab,
                    role       : tab.role
                ) {
                    NavigationStack {
                        self.destinationView(
                            for: tab,
                            tab.title
                        )
                        .onAppear {
                            self.selectedTab = tab
                        }
                    }
                    
                }
            }
        }
        .tabViewBottomAccessory(isEnabled: self.isTopAppBarVisible(self.selectedTab)) {
            
            switch self.selectedTab {
                case .wardrobe:
                    LiquidCategoryBarView(state: categoryState)
                    
                case .outfitBuilder:
                    LiquidCategoryBarView(state: seasonState)
                    
                default: EmptyView()
            }
            
        }
    }
    
    // MARK: - SubViews
    
    private var sidebarLayout: some View {
        NavigationSplitView {
        
            List(selection: $selectedTab) {
                ForEach(AppTab.allCases.filter(\.isAvailable), id: \.id) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.title, systemImage: tab.icon)
                    }
                }
            }
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            #endif
            
        } detail: {
            if let selectedTab {
                self.destinationView(
                    for: selectedTab,
                    "Atelier"
                )
                
            } else {
                ContentUnavailableView("Select view", systemImage: "arrow.left")
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(
        for tab  : AppTab,
        _   title: String
    ) -> some View {
        switch tab {
            case .wardrobe:
                InventoryView(
                    manager      : self.manager,
                    categoryState: self.categoryState,
                    title        : title
                )
            
            case .outfitBuilder:
                OutfitView(
                    manager     : self.manager,
                    seasonsState: self.seasonState,
                    title       : title
                )
            
            case .maintenance:
                Text("Maintenance Screen")
                
            case .search:
                EmptyView()
        }
    }
    
    // MARK: - Handlers
    
    private func isTopAppBarVisible(_ tab: AppTab?) -> Bool {
        
        switch tab {
            case .wardrobe:
                self.categoryState.isVisible
                
            case .outfitBuilder:
                self.seasonState.isVisible
            
            default: false
        }
        
    }
}
