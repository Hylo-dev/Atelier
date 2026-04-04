//
//  OutfitEnums.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 31/03/2026.
//

enum Tone: String, Hashable, CaseIterable {
    case none        = "All"
    case cool        = "Cool"
    case neutralCool = "Neutral Cool"
    case neutral     = "Neutral"
    case neutralWarm = "Neutral Warm"
    case warm        = "Warm"
    
    init(score: Double) {
        switch score {
            case ..<(-0.6):
                self = .cool
                
            case -0.6..<(-0.2):
                self = .neutralCool
                
            case -0.2...0.2:
                self = .neutral
                
            case 0.2...0.6:
                self = .neutralWarm
                
            case 0.6...:
                self = .warm
                
            default:
                self = .neutral
        }
    }
}
