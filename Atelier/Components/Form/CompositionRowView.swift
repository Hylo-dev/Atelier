//
//  RowInfo.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/02/26.
//

import SwiftUI



struct CompositionRowView: View {
    let fabricName: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(self.fabricName)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                
                Spacer()
                
                Text("\(Int(self.percentage))%")
                    .fontWeight(.bold)
                    .fontDesign(.default)
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.quaternary)
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(self.color)
                        .frame(width: geo.size.width * (self.percentage / 100), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }
}
