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
    
    private var imageURL: URL? {
        guard let filename = self.imagePath, !filename.isEmpty else { return nil }
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        return documentsURL.appendingPathComponent(filename)
    }
    
    var body: some View {
        let thumbnailSize = CGSize(width: 300 * 1.5, height: 300 * 1.5)
        
        LazyImage(url: self.imageURL) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .contentShape(Rectangle())
                    .transition(.opacity.animation(.easeIn(duration: 0.2)))
                
            } else {
                self.placeholderView(isError: state.error != nil)
            }
        }
        .processors([
            .resize(
                size: thumbnailSize,
                unit: .points,
                contentMode: .aspectFill,
                crop: true
            )
        ])
        .priority(.high)
        .pipeline(
            ImagePipeline {
                $0.imageCache = ImageCache.shared
                $0.dataCache = try? DataCache(
                    name: "com.atelier.thumbnails"
                )
                $0.dataCachePolicy = .storeEncodedImages
            }
        )
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
