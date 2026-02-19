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
    let size: CGSize
    
    private var imageURL: URL? {
        guard let filename = self.imagePath, !filename.isEmpty else { return nil }
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsURL.appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        
        return nil
    }
    
    var body: some View {
        if self.size.width <= 0 || self.size.height <= 0 {
            Color.clear
            
        } else {
            let scaleFactor: CGFloat = 1.5
            let pixelSize = CGSize(
                width : size.width  * scaleFactor,
                height: size.height * scaleFactor
            )
            
            LazyImage(url: self.imageURL) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .clipped()
                        .contentShape(Rectangle())
                        .transition(.opacity.animation(.easeIn(duration: 0.2)))
                    
                } else if state.error != nil {
                    self.placeholderView(isError: true)
                    
                } else {
                    self.placeholderView(isError: false)
                }
            }
            .processors([
                .resize(size: pixelSize, unit: .pixels, contentMode: .aspectFill, crop: true)
            ])
            .priority(.high)
            .pipeline(
                ImagePipeline {
                    $0.imageCache = ImageCache.shared
                    $0.dataCache = nil
                }
            )
        }
    }
    
    @ViewBuilder
    private func placeholderView(isError: Bool) -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .frame(width: size.width, height: size.height)
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
