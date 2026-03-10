//
//  View+Shimmer.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 10/03/26.
//

import SwiftUI

fileprivate struct ShimmerEffect: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.3),
                            .black,
                            .black.opacity(0.3)
                    ]),
                    startPoint: isAnimating ? .init(x: 1, y: 1) : .init(x: -0.3, y: -0.3),
                    endPoint: isAnimating ? .init(x: 1.3, y: 1.3) : .init(x: 0, y: 0)
                )
            )
            .animation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerEffect())
    }
}
