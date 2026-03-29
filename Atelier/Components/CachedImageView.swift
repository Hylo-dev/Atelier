//
//  CachedImageView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import SwiftUI
import Nuke
import NukeUI
import Glur

struct CachedImageView: View {
    let imagePath: String?
    let targetSize: CGSize
    
    init(
        imagePath : String?,
        targetSize: CGSize = CGSize(width: 200, height: 300)
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
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity.animation(.easeIn(duration: 0.2)))
                    .glur(
                        radius: 8.0,
                        offset: 0.7,
                        interpolation: 0.4,
                        direction: .down,
                        noise: 0.1,
                        drawingGroup: true
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func placeholderView(isError: Bool) -> some View {
        ZStack {
            Color.gray.opacity(0.1)
            
            if isError {
                Image(systemName: "photo.badge.exclamationmark")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                
            } else {
                ProgressView()
                    .controlSize(.regular)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
