import SwiftUI
import Nuke
import NukeUI

struct AvatarView: View {
    let pathImage: String
    let color: Color
    let icon: String
    
    private let targetSize = CGSize(width: 260, height: 347)
    
    private var imageURL: URL? {
        guard !self.pathImage.isEmpty else { return nil }
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        let fileURL = documentsURL.appendingPathComponent(pathImage)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    init(_ pathImage: String, color: Color, icon: String) {
        self.pathImage = pathImage
        self.color = color
        self.icon = icon
    }
    
    var body: some View {
        LazyImage(url: self.imageURL) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity.animation(.easeOut(duration: 0.3)))
                
            } else {
                self.fallbackView
            }
        }
        .processors([
            .resize(size: targetSize, unit: .points, contentMode: .aspectFill, crop: true)
        ])
        .priority(.veryHigh)
        .pipeline(ImagePipeline {
            $0.imageCache = ImageCache.shared
            $0.dataCache = nil
        })
        .frame(width: 260)
        .aspectRatio(3/4, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
    
    private var fallbackView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(self.color.gradient)
            
            Image(systemName: self.icon)
                .font(.system(size: 80))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}
