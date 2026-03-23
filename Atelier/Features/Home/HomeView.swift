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
    
    @Environment(\.modelContext)
    private var context
    
    @Environment(ApplianceManager.self)
    private var applianceManager
    
    
    @State
    private var selectedTab: AppTab? = .wardrobe
    
    @State
    private var manager = CaptureManager()
    
    
    
    // MARK: - Categories app bar state
    
    @State
    private var categoryState: TabFilterState = TabFilterState()
    
    
    
    // MARK: - Season app bar state
    
    @State
    private var seasonState: TabFilterState = TabFilterState()
    
    
    
    // MARK: - Laundry bar state
    @State
    private var laundryState: TabFilterState = TabFilterState()
	
	

	
    var body: some View {
        if sizeClass == .regular {
			
            self.sidebarLayout
                .onAppear {
                    let garmentDescriptor = FetchDescriptor<Garment>()
                    let laundryDescriptor = FetchDescriptor<LaundrySession>()
                    
                    if let fetchedGarments = try? context.fetch(garmentDescriptor),
                       let fetchedSessions = try? context.fetch(laundryDescriptor) {
                        applianceManager.processUnassignedGarments(fetchedGarments, fetchedSessions)
                    }
                }
            
        } else {
            self.tabLayout
                .onAppear {
                    let garmentDescriptor = FetchDescriptor<Garment>()
                    let laundryDescriptor = FetchDescriptor<LaundrySession>()
                    
                    if let fetchedGarments = try? context.fetch(garmentDescriptor),
                       let fetchedSessions = try? context.fetch(laundryDescriptor) {
                        applianceManager.processUnassignedGarments(fetchedGarments, fetchedSessions)
                    }
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
        .tabViewBottomAccessory(
            isEnabled: self.isTopAppBarVisible(self.selectedTab)
        ) {
            switch self.selectedTab {
                case .wardrobe:
                    LiquidCategoryBarView(state: categoryState)
                    
                case .outfitBuilder:
                    LiquidCategoryBarView(state: seasonState)
                    
                case .care:
                    LiquidCategoryBarView(state: laundryState)
                    
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
		
		case .care:
			CareView(
				title       : title,
				laundryState: laundryState
			)
			
		case .search:
			SearchView(
				title: title
			)
        }
    }
	
    
    // MARK: - Handlers
    
    private func isTopAppBarVisible(_ tab: AppTab?) -> Bool {
        
        switch tab {
            case .wardrobe:
                categoryState.isToolbarEnabled
                
            case .outfitBuilder:
                seasonState.isToolbarEnabled
                
            case .care:
                laundryState.isToolbarEnabled
			
            default: false
        }
        
    }
}
