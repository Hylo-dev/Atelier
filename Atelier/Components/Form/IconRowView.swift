//
//  IconRow.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/03/26.
//

import SwiftUI



struct IconRowView: View {
    
    let systemName: String
    let title     : String
    
    init(
        _ systemName: String,
          title     : String
    ) {
        self.systemName = systemName
        self.title      = title
    }
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                        
            Text(title)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        
    }
    
}
