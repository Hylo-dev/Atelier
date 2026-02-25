//
//  ModelCard.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI

struct ModelCardView: Equatable, View {
    let title      : String
    let subheadline: String?
    let imagePath  : String?
    
    init(
        title      : String,
        subheadline: String? = nil,
        imagePath  : String?
    ) {
        self.title       = title
        self.subheadline = subheadline
        self.imagePath   = imagePath
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            Color.secondary.opacity(0.1)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    
                    
                    if let path = self.imagePath {
                        CachedImageView(imagePath: path)
                        
                    } else {
                        Image(systemName: "hanger")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary.opacity(0.3))
                    }
                }
                .clipShape(Rectangle())
            
            if self.imagePath != nil {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black.opacity(0.6), location: 0.5),
                        .init(color: .black.opacity(0.8), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(self.title)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                if let subhead = self.subheadline {
                    Text(subhead)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .frame(
                maxWidth : .infinity,
                alignment: .leading
            )
            .background(.clear)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .continuous))
#if os(macOS)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
#endif
    }
}
