//
//  ModelCard.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/02/26.
//

import SwiftUI

struct ModelCardView: View {
    let title      : String
    let subheadline: String?
    let imagePath  : String?
    
    init(
        title      : String,
        subheadline: String?,
        imagePath  : String?
    ) {
        self.title       = title
        self.subheadline = subheadline
        self.imagePath   = imagePath
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            Color.secondary.opacity(0.1)
                .aspectRatio(4/4, contentMode: .fit)
                .overlay {
                    GeometryReader { proxy in
                        
                        if let path = self.imagePath {
                            CachedImageView(imagePath: path, size: proxy.size)
                            
                        } else {
                            Image(systemName: "hanger")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary.opacity(0.3))
                                .frame(width: proxy.size.width, height: proxy.size.height)
                        }
                    }
                }
                .clipShape(Rectangle())
            
            // --- IL TUO BLUR CUSTOM, FIXATO ---
            TransparentBlurView()
                .frame(height: 80)
                .blur(radius: 6, opaque: true)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .black, location: 0.3),
                            .init(color: .black, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(self.title)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                    .shadow(color: .black, radius: 5)
                
                if let subhead = self.subheadline {
                    Text(subhead)
                        .font(.subheadline)
                        .fontDesign(.rounded)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .shadow(color: .black, radius: 5)
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

fileprivate struct TransparentBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemThickMaterial)
        )
        
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        Task {
            if let backdropLayer = uiView.layer.sublayers?.first {
                backdropLayer.filters = []
            }
        }
    }
}
