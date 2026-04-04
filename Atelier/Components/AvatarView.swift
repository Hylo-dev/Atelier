import SwiftUI
import Nuke
import NukeUI

struct AvatarView: View {
    private let pathImage: String?
    
    private let color: [Color]
    private let gradient: Bool
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
        color      : [Color]  = [.accentColor],
        gradient   : Bool     = false,
        icon       : String,
        uiImage    : UIImage? = nil
    ) {
        self.pathImage    = pathImage
        self.color        = color
        self.gradient     = gradient
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
        
        return ZStack {
            Rectangle()
                .fill(
                    !gradient ?
                    AnyShapeStyle(color.first!.gradient) :
                        AnyShapeStyle(
                            MeshGradient(
                                width : 3,
                                height: 3,
                                points: [
                                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                                ],
                                colors: generateEnrichedPalette(from: color)
                            )
                        )
                )
            
            Image(systemName: self.icon)
                .font(.system(size: 80))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
    
    private func generateEnrichedPalette(
        from outfitColors: [Color]
    ) -> [Color] {
        
        guard !outfitColors.isEmpty else {
            return Array(repeating: Color(white: 0.9), count: 9)
        }
        
        let softWhite  = Color(white: 0.60)
        let deepShadow = Color(white: 0.25)
        
        var finalPalette: [Color] = []
        
        if outfitColors.count == 1 {
            let c = outfitColors[0]
            finalPalette = [c, c.opacity(0.8), softWhite,
                            c.opacity(0.6), c, c.opacity(0.4),
                            deepShadow, c.opacity(0.7), softWhite]
            
        } else if outfitColors.count == 2 {
            let c1 = outfitColors[0]
            let c2 = outfitColors[1]
            finalPalette = [
                c1, softWhite, c2,
                c2.opacity(0.4), c1.opacity(0.9), deepShadow,
                softWhite, c2, c1
            ]
            
        } else {
            
            for i in 0..<9 {
                let baseColor = outfitColors[i % outfitColors.count]
                
                if i == 4 {
                    finalPalette.append(softWhite)
                    
                } else if i == 7 {
                    finalPalette.append(deepShadow)
                    
                } else {
                    finalPalette.append(baseColor)
                }
            }
        }
        
        return finalPalette
    }
}
