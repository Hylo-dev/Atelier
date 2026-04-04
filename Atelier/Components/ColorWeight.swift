//
//  ColorWeight.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 31/03/2026.
//

import SwiftUI


struct ColorWeight: Identifiable, Codable, Hashable {
    let id    : String
    let weight: Double
    
    static nonisolated func from(_ strings: [String]) -> [ColorWeight] {
        let total = Double(strings.count)
        guard total > 0 else { return [] }
        
        let counts = strings.reduce(into: [:]) { counts, color in
            counts[color, default: 0] += 1
        }
        
        return counts.map { color, count in
            ColorWeight(
                id: color,
                weight: (Double(count) * 100.0) / total
            )
        }
    }
    
    @inline(__always)
    func toColor() -> Color {
        return Color(hex: id)
    }
}
