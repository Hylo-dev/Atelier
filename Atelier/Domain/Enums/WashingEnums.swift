//
//  WashingEnums.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/03/26.
//

import Foundation



enum WashingColorGroup: String, Codable, CaseIterable {
    case whites  = "Whites"
    case darks   = "Darks"
    case pastels = "Pastels"
    case vibrant = "Vibrant"
    
    /// Restituisce la categoria di lavaggio basata sul codice Hex
    static func classify(_ hex: String) -> WashingColorGroup {
        let rgb = hexToRGB(hex)
        let (_, s, b) = rgbToHSB(r: rgb.r, g: rgb.g, b: rgb.b)
        
        // 1. BIANCHI: Alta luminosità, saturazione quasi inesistente
        if b > 0.85 && s < 0.15 {
            return .whites
        }
        
        // 2. SCURI: Bassa luminosità (es. Blu Navy, Nero, Bordeaux)
        // Alziamo la soglia a 0.35 per catturare in sicurezza tutti i toni profondi
        if b < 0.35 {
            return .darks
        }
        
        // 3. CHIARI / PASTELLO (L'Azzurro di cui parlavi)
        // Alta luminosità, ma saturazione moderata/bassa.
        // Rischiano di assorbire il colore dagli altri capi.
        if b > 0.70 && s < 0.50 {
            return .pastels
        }
        
        // 4. COLORI VIVIDI: Tutto il resto
        // Colori saturi e medi che potrebbero stingere (es. Rosso, Blu Royal)
        return .vibrant
    }
    
    // MARK: - Helpers Matematici
    
    /// Converte stringa Hex (es. "#FF0000" o "FF0000") in valori R, G, B da 0 a 1
    static func hexToRGB(_ hex: String) -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return (0.5, 0.5, 0.5) // Fallback grigio se codice errato
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return (
            CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            CGFloat(rgbValue & 0x0000FF) / 255.0
        )
    }
    
    /// Converte RGB in HSB (Hue, Saturation, Brightness)
    /// H: 0-360, S: 0-1, B: 0-1
    static func rgbToHSB(r: CGFloat, g: CGFloat, b: CGFloat) -> (h: CGFloat, s: CGFloat, b: CGFloat) {
        let minV = min(r, g, b)
        let maxV = max(r, g, b)
        let delta = maxV - minV
        
        var hue: CGFloat = 0
        if delta != 0 {
            if maxV == r {
                hue = (g - b) / delta
            } else if maxV == g {
                hue = 2 + (b - r) / delta
            } else {
                hue = 4 + (r - g) / delta
            }
            hue *= 60
            if hue < 0 { hue += 360 }
        }
        
        let saturation = maxV == 0 ? 0 : (delta / maxV)
        let brightness = maxV
        
        return (hue, saturation, brightness)
    }
    
    static func from(hex: String) -> WashingColorGroup {
        return self.classify(hex)
    }
}



enum WashingAgitation: String, Sendable, Equatable {
    case normal
    case reduced     // "Synthetics" / "Permanent Press"
    case gentle      // "Delicates" / "Wool"
    case none        // Non lavare / Non centrifugare
    
    var program: Program {
        switch self {
            case .normal:
                    .standard
                
            case .reduced:
                    .mix
                
            case .gentle:
                    .delicate
                
            case .none:
                    .notWash
        }
    }
}
