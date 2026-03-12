//
//  ModelCard.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI

struct CardView<Content: View>: View {
    let title      : String
    let subheadline: String?
    let gradient   : Color
    let content    : Content
    
    init(
        title      : String,
        subheadline: String? = nil,
        gradient   : Color   = Color(UIColor.tertiaryLabel),
        @ViewBuilder content: () -> Content
    ) {
        self.title       = title
        self.subheadline = subheadline
        self.gradient    = gradient
        self.content     = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            Color.secondary.opacity(0.15)
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .leading) {
                    content
                }
                .clipShape(Rectangle())
            
            LinearGradient(
                colors: [
                    gradient,
                    gradient.opacity(0.8),
                    gradient.opacity(0.6),
                    gradient.opacity(0.3),
                    gradient.opacity(0.1),
                    .clear
                ],
                startPoint: .bottom,
                endPoint  : UnitPoint(x: 0.5, y: 0.3)
            )
            .frame(height: 80)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(self.title)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                if let subhead = self.subheadline {
                    Text(subhead)
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.bottom, 12)
            .padding(.horizontal, 18)
            .frame(
                maxWidth : .infinity,
                alignment: .leading
            )
            .background(.clear)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26)
                .stroke(.tertiary, lineWidth: 0.75)
        }
    }
}
