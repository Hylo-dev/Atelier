//
//  ModelCard.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI

struct ModelCard: View {
    let item: Garment
    
    init(_ item: Garment) {
        self.item = item
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Color.secondary.opacity(0.1)
                .aspectRatio(3/4, contentMode: .fit)
                .overlay {
                    GeometryReader { proxy in
                        if let path = item.imagePath, let image = ImageStorage.loadImage(from: path) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .contentShape(Rectangle())
                                .clipped()
                        } else {
                            Image(systemName: "hanger")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary.opacity(0.3))
                                .frame(width: proxy.size.width, height: proxy.size.height)
                        }
                    }
                }
                .clipShape(Rectangle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(self.item.name)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Text(self.item.brand ?? " ")
                    .font(.subheadline)
                    .foregroundStyle(self.item.brand == nil ? .clear : .secondary)
                    .lineLimit(1)
                
            }
            .padding(12)
            .frame(
                maxWidth : .infinity,
                alignment: .leading
            )
            .background(Color(.secondarySystemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .continuous))
#if os(macOS)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
#endif
    }
}
