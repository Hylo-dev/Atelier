//
//  AppTab.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case inventory
    case outfitBuilder
    case maintenance
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .inventory    : return "Inventory"
        case .outfitBuilder: return "Outfit"
        case .maintenance  : return "Manutenzione"
        }
    }
    
    var icon: String {
        switch self {
        case .inventory    : return "archivebox"
        case .outfitBuilder: return "tshirt"
        case .maintenance  : return "wrench.and.screwdriver"
        }
    }
    
    var role: TabRole? {
        return switch self {
            default:  nil
        }
    }
    
    var isAvailable: Bool {
        #if os(macOS)
        if self == .scanner { return false }
        #endif
        
        return true
    }
}
