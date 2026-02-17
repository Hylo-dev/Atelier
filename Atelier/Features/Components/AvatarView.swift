//
//  AvatarView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 17/02/26.
//

import SwiftUI

struct AvatarView: View {
    let pathImage: String
    let color    : Color
    let icon     : String
    
    init(
        _ pathImage: String,
        color      : Color,
        icon       : String
    ) {
        self.pathImage = pathImage
        self.color     = color
        self.icon      = icon
    }
    
    var body: some View {
        Group {
            if let image = ImageStorage.loadImage(from: self.pathImage) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(self.color.gradient)
                    
                    Image(systemName: self.icon)
                        .font(.system(size: 80))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .frame(width: 260)
        .aspectRatio(3/4, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}
