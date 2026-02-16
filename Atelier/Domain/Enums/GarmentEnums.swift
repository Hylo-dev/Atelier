//
//  GarmentEnums.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/02/26.
//

import Foundation

enum GarmentType: String, Codable, CaseIterable, Identifiable {
    case top
    case bottom
    case outerwear
    case footwear
    case accessory
    
    var id: String { rawValue }
}

enum WashingSymbol: String, Codable, CaseIterable, Identifiable {
    case doNotWash   = "do_not_wash"
    case handWash    = "hand_wash"
    case tumbleDryOk = "tumble_dry"
    
    var id: String { rawValue }
    
    var label: String {
        return switch self {
            case .doNotWash  : "Do not wash"
            case .handWash   : "Handwash"
            case .tumbleDryOk: "Tumble dry"
        }
    }
}
