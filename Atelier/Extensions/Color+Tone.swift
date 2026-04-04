//
//  Color+Tone.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 01/04/2026.
//

import SwiftUI

extension Color {
    nonisolated var temperatureValue: Double {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
                
        let hueDegrees = h * 360
        let rawTemperature = cos((hueDegrees - 30) * .pi / 180)
        
        let flexibleTemperature = Double(rawTemperature) * Double(s)
        
        if b < 0.05 { return 0.0 }
        
        return flexibleTemperature
    }
}
