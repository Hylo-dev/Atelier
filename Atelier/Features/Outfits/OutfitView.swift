//
//  OutfitView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI
import SwiftData

struct OutfitView: View {
    
    // MARK: - Param values
    
    @Bindable
    var manager: CaptureManager
    
    @Bindable
    var seasonsState: TabFilterState
    
    var title: String
    
    
    
    @State
    private var alertManager = AlertManager()
    
    
    
    // MARK: - Edit Sheet value
    
    @State
    private var selectedItem: Outfit?
    
    @State
    private var navigatedOutfit: Outfit?
    
    @State
    private var isDeleted: Bool = false
    
    
    
    // MARK: - Private Attributes values
    
    @Environment(\.modelContext)
    private var context
    
    @Environment(OutfitManager.self)
    private var outfitManager: OutfitManager
    
    @Environment(GarmentManager.self)
    private var garmentManager: GarmentManager
    
    @Environment(ApplianceManager.self)
    private var applianceManager: ApplianceManager
    
    
    
    @Query(
        sort : \Outfit.lastWornDate,
        order: .reverse
    )
    private var outfits: [Outfit]
    
    @Query(
        sort : \LaundrySession.dateCreated,
        order: .reverse
    )
    private var laundrySessions: [LaundrySession]
    
    
    
    // MARK: - Add Outfit Sheet values
    
    @State
    private var isAddOutfitSheetVisible: Bool = false
    
    
    
    // MARK: - Filter Outfit Sheet values
    
    @State
    private var filter = FilterOutfitConfig()
    
    @State
    private var isFilterSheetVisible: Bool = false
    
    
    
    // MARK: - Static properties
    
    static private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 20)
    ]
    
    
    
    // MARK: - Refresh Trigger
    
    private var outfitsUpdateTrigger: Int {
        var hasher = Hasher()
        
        for outfit in outfits {
            hasher.combine(outfit.id)
            hasher.combine(outfit.name)
            hasher.combine(outfit.season.title)
            hasher.combine(outfit.fullLookImagePath)
            hasher.combine(outfit.garments.count)
            hasher.combine(outfit.lastWornDate)
        }
        
        return hasher.finalize()
    }
    
    var body: some View {
        Group {
            if outfits.isEmpty {
                ContentUnavailableView(
                    "Outfits Empty",
                    systemImage: "tshirt",
                    description: Text("Time to create your drip")
                )
                .containerRelativeFrame(.vertical)
                
            } else if outfitManager.visibleOutfits.isEmpty {
                ContentUnavailableView(
                    "No Outfits Found",
                    systemImage: "magnifyingglass",
                    description: Text("Try adjusting your filters to see more results from your wardrobe.")
                )
                .containerRelativeFrame(.vertical)
                
            } else {
                LiquidPagingView(
                    selection  : self.$seasonsState.selection,
                    onProgressChange: { newVal in
                        if self.seasonsState.progress != newVal {
                            self.seasonsState.progress = newVal
                        }
                    },
                    items      : self.seasonsState.items,
                    isEnabled  : self.seasonsState.isPagesEnabled
                ) { season in
                    self.scrollableGrid(for: season)
                }
                .ignoresSafeArea(.container, edges: .top)
                
            }
        }
        .sensoryFeedback(.success, trigger: isDeleted)
        .onChange(of: outfitsUpdateTrigger, initial: true) {
            self.updateData()
        }
        .onChange(of: self.filter) {
            self.updateData()
        }
        .onChange(of: filter.isFiltering) { _, newValue in
            seasonsState.hiddenSectionBar = newValue
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
            
            if !outfits.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Filter", systemImage: "line.3.horizontal.decrease") {
                        self.isFilterSheetVisible = true
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus") { self.isAddOutfitSheetVisible = true }
            }
        }
        .navigationDestination(item: $navigatedOutfit) { item in
            InfoOutfitView(item)
                .onAppear {
                    withAnimation {
                        seasonsState.hiddenSectionBar = true
                    }
                }
        }
        .sheet(isPresented: self.$isAddOutfitSheetVisible) {
            NavigationStack {
                OutfitEditorView()
            }
        }
        .sheet(item: self.$selectedItem) { outfit in
            NavigationStack {
                OutfitEditorView(outfit)
            }
        }
        .sheet(isPresented: self.$isFilterSheetVisible) {
            FilterOutfitView(filter: self.$filter)
        }
        .alert(
            alertManager.title,
            isPresented: $alertManager.isPresent
        ) {
            
        } message: {
            Text(alertManager.message)
        }
        .onChange(of: navigatedOutfit) { old, newValue in
            if newValue == nil {
                withAnimation {
                    seasonsState.hiddenSectionBar = false
                }
            }
        }
    }
    
    
    // MARK: - Views
    
    @ViewBuilder
    private func scrollableGrid(for season: String) -> some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: Self.columns, spacing: 20) {
                
                ForEach(outfitManager.groupedOutfits[season] ?? [], id: \.id) { item in
                    
                    let subTitle = item.garments.count <= 1 ?
                    "Incomplete outfit" : nil
                    OutfitContextCard(
                        outfit          : item,
                        sessions        : laundrySessions,
                        garmentManager  : garmentManager,
                        applianceManager: applianceManager,
                        manager         : self.outfitManager,
                        subTitleAlert   : subTitle,
                        selectedItem    : self.$selectedItem,
                        navigatedOutfit : $navigatedOutfit
                        
                    ) { title, message in
                        alertManager.title     = title
                        alertManager.message   = message
                        alertManager.isPresent = true
                    }
                    .equatable()
                    .id(item.id)
                }
            }
            .padding(.horizontal, 16)
        }
        .contentMargins(.top, 150, for: .scrollContent)
        .scrollIndicators(.hidden)
    }
    
    
    // MARK: - Handlers
    
    @inline(__always)
    private func updateData() {
        self.outfitManager.processOutfits(self.outfits, with: self.filter)
        
        if self.seasonsState.items != outfitManager.availableSeasons {
            self.seasonsState.items = outfitManager.availableSeasons
        }
    }
}

fileprivate
struct OutfitContextCard: View, Equatable {
    let outfit          : Outfit
    let sessions        : [LaundrySession]
    let garmentManager  : GarmentManager
    let applianceManager: ApplianceManager
    let manager         : OutfitManager
    let subTitleAlert   : String?
    let onError         : (String, String) -> Void
    
    @Binding
    var selectedItem: Outfit?
    
    @Binding
    var navigatedOutfit: Outfit?
    
    // MARK: - Deleted target
    @State
    private var taskDeletedCompleted: Bool = false
    
    
    init(
        outfit          : Outfit,
        sessions        : [LaundrySession],
        garmentManager  : GarmentManager,
        applianceManager: ApplianceManager,
        manager         : OutfitManager,
        subTitleAlert   : String?,
        selectedItem    : Binding<Outfit?>,
        navigatedOutfit : Binding<Outfit?>,
        onError         : @escaping (String, String) -> Void
    ) {
        
        self.outfit = outfit
        self.sessions = sessions
        self.garmentManager = garmentManager
        self.applianceManager = applianceManager
        self.manager = manager
        self.subTitleAlert = subTitleAlert
        self._selectedItem = selectedItem
        self._navigatedOutfit = navigatedOutfit
        self.onError = onError
    }
    
    static func == (lhs: OutfitContextCard, rhs: OutfitContextCard) -> Bool {
        return lhs.outfit.id == rhs.outfit.id &&
        lhs.outfit.name == rhs.outfit.name &&
        lhs.outfit.fullLookImagePath == rhs.outfit.fullLookImagePath &&
        lhs.subTitleAlert == rhs.subTitleAlert &&
        lhs.outfit.garments.count == rhs.outfit.garments.count
    }
    
    var body: some View {
        
        Button {
            navigatedOutfit = outfit
            
        } label: {
            ModelCardView(
                title      : self.outfit.name,
                subheadline: self.subTitleAlert,
                imagePath  : outfit.fullLookImagePath
            )
            .opacity(self.subTitleAlert != nil ? 0.7 : 1)
            .contextMenu {
                self.contextMenuButtons(for: self.outfit)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: self.taskDeletedCompleted)
        
    }
    
    @ViewBuilder
    private func contextMenuButtons(for item: Outfit) -> some View {
        
        Button {
            do {
                try manager.moveOutfitToWash(
                    for           : outfit,
                    garmentManager: garmentManager,
                    in            : sessions,
                    processGarment: applianceManager
                )
            } catch {
                onError(
                    "Error on move state",
                    error.localizedDescription
                )
            }
            
        } label: {
            Label("Wash Entire Outfit", systemImage: "washer")
        }
        
        
        Button {
            do {
                try manager.toggleOutfitLoan(outfit)
                
            } catch {
                onError(
                    "Error on set Loan State",
                    error.localizedDescription
                )
            }
            
        } label: {
            let isOnLoan = outfit.isOnLoan
            Label(
                isOnLoan ? "Mark Outfit as Returned" : "Lend Entire Outfit",
                systemImage: isOnLoan ? "arrow.uturn.backward" : "person.2"
            )
        }
        
        
        
        Divider()
        
        
        
        Button {
            do {
               try manager.logOutfitWear(
                    for           : item,
                    garmentManager: garmentManager,
                    in            : sessions,
                    processGarment: applianceManager
                )
            } catch {
                onError(
                    "Error on loggin wear",
                    error.localizedDescription
                )
            }
            
        } label: {
            Label("Log wear", systemImage: "checkmark.seal")
        }
        
        
        
        Divider()
        
        
        
        Button {
            self.selectedItem = item
        } label: {
            Label("Edit Details", systemImage: "pencil")
        }
        
        
        Button(role: .destructive) {
            do {
                try self.manager.delete(item)
                self.taskDeletedCompleted.toggle()
            } catch {
                onError(
                    "Error on delete outfit",
                    error.localizedDescription
                )
            }
            
        } label: {
            Label("Delete", systemImage: "trash")
        }
        
    }
}
