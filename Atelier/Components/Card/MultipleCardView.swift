//
//  MultipleCardView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/03/26.
//

import SwiftUI

struct MultipleCardView: Equatable, View {
    let title      : String
    let subheadline: String?
    let items      : [Garment]
    
    init(
        title      : String,
        subheadline: String? = nil,
        items      : [Garment]
    ) {
        self.title       = title
        self.subheadline = subheadline
        self.items       = items
    }
    
    var body: some View {
        
        CardView(
            title      : self.title,
            subheadline: self.subheadline,
            gradient   : .black
        ) {
            if !items.isEmpty {
                
                ZStack(alignment: .bottomLeading) {
                    ForEach(
                        Array(items.prefix(3).enumerated().reversed()),
                        id: \.element.id
                    ) { index, garment in
                        
                        CachedImageView(
                            imagePath : garment.imagePath!,
                            targetSize: CGSize(width: 100, height: 100)
                        )
                        .frame(width: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .rotationEffect(
                            .degrees(
                                Double(index) * 3.5
                            ),
                            anchor: .bottomLeading
                        )
                        .offset(
                            x: CGFloat(index) * 30,
                            y: CGFloat(index) * -5
                        )
                        .shadow(color: .black.opacity(0.25), radius: 3, x: 2, y: 2)
                    }
                }
                .padding(.bottom, 55)
                .padding(.top, 17.5)
                .padding(.horizontal, 17.5)
                
            } else {
                Image(systemName: "washer")
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
