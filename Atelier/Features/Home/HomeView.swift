//
//  HomeView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.horizontalSizeClass)
    private var sizeClass
    
    @State
    private var selectedTab: AppTab? = .wardrobe
    
    @State
    private var manager = CaptureManager()
    
    var body: some View {
        
        if sizeClass == .regular {
            self.sidebarLayout
            
        } else { self.tabLayout }
    }
    
    private var tabLayout: some View {
        TabView(selection: self.$selectedTab) {
            
            ForEach(AppTab.allCases.filter(\.isAvailable), id: \.id) { tab in
                
                Tab(tab.title, systemImage: tab.icon, value: tab, role: tab.role) {
                    NavigationStack {
                        destinationView(for: tab)
                            .toolbarTitleDisplayMode(.large)
                            .navigationTitle(tab.title)
                    }
                    
                }
            }
        }
        .tint(.teal)
    }
    
    private var sidebarLayout: some View {
        NavigationSplitView {
        
            List(selection: $selectedTab) {
                ForEach(AppTab.allCases.filter(\.isAvailable)) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.title, systemImage: tab.icon)
                    }
                }
            }
            .navigationTitle("Atelier")
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            #endif
            
        } detail: {
            if let selectedTab {
                destinationView(for: selectedTab)
                
            } else {
                ContentUnavailableView("Select view", systemImage: "arrow.left")
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for tab: AppTab) -> some View {
        switch tab {
            case .wardrobe:
                InventoryView(manager: self.manager)
            
            case .outfitBuilder:
                Text("Schermata Outfit")
            
            case .maintenance:
                Text("Schermata Manutenzione")
        }
    }
}
