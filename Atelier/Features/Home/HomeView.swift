//
//  HomeView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.horizontalSizeClass)
    private var sizeClass
    
    @State
    private var selectedTab: AppTab? = .wardrobe
    
    @State
    private var manager = CaptureManager()
    
    @State
    private var categories: [String] = ["All"]
    
    @State
    private var selectedCategory: String? = "All"
    
    @State
    private var tabProgress: CGFloat = 0
    
    
    var body: some View {
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
                    }
                    
                }
            }
        }
        .tabViewBottomAccessory {
            LiquidCategoryBarView(
                selection    : self.$selectedCategory,
                tabProgress  : self.$tabProgress,
                items        : self.categories,
                titleProvider: { $0 ?? "" }
            )
        }
    }
    
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
                    manager            : self.manager,
                    title              : title,
                    selectedCategory   : self.$selectedCategory,
                    tabProgress        : self.$tabProgress,
                    availableCategories: self.$categories
                
                )
            
            case .outfitBuilder:
                OutfitView(manager: self.manager)
            
            case .maintenance:
                Text("Maintenance Screen")
                
            case .search:
                EmptyView()
        }
    }
}
