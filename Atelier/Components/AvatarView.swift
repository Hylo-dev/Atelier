import SwiftUI
import Nuke
import NukeUI

struct AvatarView: View {
    private let pathImage: String?
    
    private let color: Color
    private let icon: String
        
    private let uiImage: UIImage?
    
    
    
    private static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private var imageURL: URL? {
        if let path = self.pathImage {
            guard !path.isEmpty else { return nil }
            return Self.documentsDirectory.appendingPathComponent(path)
        }
        return nil
    }
    
    
    
    init(
        _ pathImage: String?,
        color      : Color = .accentColor,
        icon       : String,
        uiImage    : UIImage? = nil
    ) {
        self.pathImage    = pathImage
        self.color        = color
        self.icon         = icon
        self.uiImage      = uiImage
    }
    
    var body: some View {
        
        Group {
            if let uiImage = self.uiImage {
                Color.clear
                    .overlay(
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    )
                    .clipped()
                    .transition(.opacity.animation(.easeOut(duration: 0.3)))
                
            } else if let url = self.imageURL{
                Color.clear
                    .overlay(
                        LazyImage(url: url) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .transition(.opacity.animation(.easeOut(duration: 0.3)))
                            }
                        }
                        .processors([
                            .resize(
                                size: CGSize(width: 600, height: 800),
                                unit: .points,
                                contentMode: .aspectFill,
                                crop: true
                            )
                        ])
                        .priority(.veryHigh)
                        .pipeline(AtelierEnvironment.ephemeralPipeline)
                        
                    )
                    .clipped()
                
            } else {
                self.fallbackView
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
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
