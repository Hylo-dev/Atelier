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
    case care
    case search
    
    var id: String { rawValue }
    
    var title: String {
        return switch self {
            case .wardrobe     : "Wardrobe"
            case .outfitBuilder: "Outfit"
            case .care         : "Care"
            case .search       : "Search"
        }
    }
    
    var icon: String {
        return switch self {
            case .wardrobe     : "cabinet"
            case .outfitBuilder: "tshirt"
            case .care         : "sparkles.2"
            case .search       : "magnifyingglass"
        }
    }
    
    var role: TabRole? {
        return switch self {
            case .search: .search
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
