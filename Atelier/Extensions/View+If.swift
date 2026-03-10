//
//  View+If.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 10/03/26.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        
        if condition {
            transform(self)
            
        } else { self }
    }
}
