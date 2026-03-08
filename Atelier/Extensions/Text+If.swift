//
//  Text+If.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/03/26.
//

import SwiftUI

extension Text {
    
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
