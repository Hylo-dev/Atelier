//
//  ModelCardView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/03/26.
//

import SwiftUI

struct ModelCardView: Equatable, View {
    let title      : String
    let subheadline: String?
    let imagePath  : String?
    
    init(
        title      : String,
        subheadline: String? = nil,
        imagePath  : String?
    ) {
        self.title       = title
        self.subheadline = subheadline
        self.imagePath   = imagePath
    }
    
    var body: some View {
        
        CardView(
            title      : self.title,
            subheadline: self.subheadline
        ) {
            if let path = self.imagePath {
                CachedImageView(imagePath: path)
                
            } else {
                Image(systemName: "hanger") 
                    .font(.largeTitle)
                    .foregroundStyle(.tertiary)
                    .frame(
                        maxWidth : .infinity,
                        maxHeight: .infinity
                    )
            }
        }
    }
}
