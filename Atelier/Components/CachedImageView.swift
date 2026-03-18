//
//  CachedImageView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import SwiftUI
import Nuke
import NukeUI

struct CachedImageView: View {
    let imagePath: String?
    let targetSize: CGSize // Aggiungi questo parametro
    
    init(
        imagePath : String?,
        targetSize: CGSize = CGSize(width: 150, height: 150)
    ) {
        self.imagePath  = imagePath
        self.targetSize = targetSize
    }
    
    private var imageURL: URL? {
        guard let filename = self.imagePath, !filename.isEmpty,
              let documentsURL = AtelierEnvironment.documentsDirectory else {
            return nil
        }
        
        return documentsURL.appendingPathComponent(filename)
    }
    
    var body: some View {
        LazyImage(url: self.imageURL) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .contentShape(Rectangle())
                    .transition(
                        .opacity
                        .animation(
                            .easeIn(duration: 0.2)
                        )
                    )
                
            } else {
                self.placeholderView(isError: state.error != nil)
            }
        }
        .processors([
            .resize(
                size: targetSize,
                unit: .points,
                contentMode: .aspectFill,
                crop: true
            )
        ])
        .pipeline(AtelierEnvironment.imagePipeline)
    }
    
    @ViewBuilder
    private func placeholderView(isError: Bool) -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .overlay {
                if isError {
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView()
                }
            }
    }
}
