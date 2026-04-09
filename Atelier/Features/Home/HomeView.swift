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
    private var wardrobeState = TabFilterService()
    
    @State
    private var outfitState = TabFilterService()
    
    @State
    private var careState = TabFilterService()
	
    
    private var currentState: TabFilterService {
        switch selectedTab {
            case .wardrobe     : wardrobeState
            case .outfitBuilder: outfitState
            case .care         : careState
            default            : wardrobeState
        }
    }
	
    var body: some View {
        Group {
            if sizeClass == .regular {
                self.sidebarLayout
                
            } else {
                self.tabLayout
            }
        }
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
						destinationView(
							for: tab,
							tab.title
						)
						.onAppear {
                            selectedTab = tab
						}
					}
                }
            }
        }
        .tabViewBottomAccessory(isEnabled: currentState.isToolbarEnabled) {
            LiquidCategoryBarView(state: currentState)
        }
    }
    
    // MARK: - SubViews
    
    @ViewBuilder
    private func destinationView(
        for tab  : AppTab,
        _   title: String
    ) -> some View {
        switch tab {
            case .wardrobe:
                WardrobeView(
                    title        : title,
                    wardrobeState: wardrobeState
                )
                
            case .outfitBuilder:
                OutfitView(
                    outfitState: outfitState,
                    title       : title
                )
                
            case .care:
                CareView(
                    title       : title,
                    laundryState: careState
                )
                
            case .search:
                SearchView(
                    title: title
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
}
