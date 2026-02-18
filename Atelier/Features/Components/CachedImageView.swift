//
//  CachedImageView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import SwiftUI

fileprivate class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

struct CachedImageView: View {
    let imagePath: String?
    let size     : CGSize
    
    @State
    private var image: UIImage? = nil
    
    @State
    private var isLoading = true
    
    var body: some View {
        
        if self.size.width <= 0 || self.size.height <= 0 {
            Color.clear
            
        } else {
            ZStack {
                if let image = self.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: self.size.width, height: self.size.height)
                        .contentShape(Rectangle())
                        .clipped()
                    
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: self.size.width, height: self.size.height)
                        .overlay {
                            if self.isLoading {
                                ProgressView()
                                
                            } else {
                                Image(systemName: "photo.badge.exclamationmark")
                                    .foregroundStyle(.secondary)
                            }
                        }
                }
            }
            .task(id: imagePath) {
                await loadImage()
            }
        }
    }
    
    private func loadImage() async {
        guard let filename = imagePath, !filename.isEmpty else {
            print("Filename is empty or nil")
            await MainActor.run { isLoading = false }
            return
        }
        
        let cacheKey = filename as NSString
        if let cachedImage = ImageCache.shared.object(forKey: cacheKey) {
            await MainActor.run {
                self.image     = cachedImage
                self.isLoading = false
            }
            
            return
        }
        
        let loadedImage = await Task.detached(
            priority: .userInitiated
        ) { () -> UIImage? in
            
            guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
            }
            let fileURL = documentsURL.appendingPathComponent(filename)
            
            do {
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    print("File not found (Dynamic path): \(fileURL.path)")
                    return nil
                }
                
                let data = try Data(contentsOf: fileURL)
                guard let uiImage = UIImage(data: data) else {
                    return nil
                }
                
                _ = uiImage.cgImage
                
                return uiImage
                
            } catch {
                print("Error load image\(error.localizedDescription)")
                return nil
            }
            
        }.value
        
        await MainActor.run {
            if let loadedImage {
                ImageCache.shared.setObject(loadedImage, forKey: cacheKey)
                
                withAnimation(.easeIn(duration: 0.2)) {
                    self.image = loadedImage
                }
            }
            self.isLoading = false
        }
    }
}
