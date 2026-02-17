//
//  AppTab.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case wardrobe
    case outfitBuilder
    case maintenance
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .wardrobe     : return "Wardrobe"
        case .outfitBuilder: return "Outfit"
        case .maintenance  : return "Cure"
        }
    }
    
    var icon: String {
        switch self {
        case .wardrobe     : return "cabinet"
        case .outfitBuilder: return "tshirt"
        case .maintenance  : return "sparkles.2"
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
