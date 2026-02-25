import SwiftUI
import Nuke
import NukeUI

struct AvatarView: View {
    let pathImage: String?
    let color: Color
    let icon: String
    
    let uiImage: UIImage?
    
    
    private var imageURL: URL? {
        
        if let path = self.pathImage {
            guard !path.isEmpty else { return nil }
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            return documentsURL.appendingPathComponent(path)
        }
        
        return nil
    }
    
    init(
        _ pathImage: String?,
        color: Color,
        icon: String,
        uiImage: UIImage? = nil
    ) {
        self.pathImage = pathImage
        self.color     = color
        self.icon      = icon
        self.uiImage   = uiImage
    }
    
    var body: some View {
        
        Group {
            if let uiImage = self.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                
            } else {
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
                .priority(.veryHigh)
                .pipeline(AtelierEnvironment.ephemeralPipeline)
            }
            
        }
        .frame(width: 260)
        .aspectRatio(3/4, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        //.shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
    
    private var fallbackView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(self.color.gradient)
            
            Image(systemName: self.icon)
                .font(.system(size: 80))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}
