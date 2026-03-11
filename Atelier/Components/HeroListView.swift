//
//  HeroListView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/03/26.
//

import SwiftUI

struct HeroListView<TitleContent: View, BodyContent: View>: View {
    
    private let imagePath       : String?
    
    @Binding
    private var isImageClicked  : Bool
    
    private let colorPlaceholder: Color
    private let iconPlaceholder : String
    
    private let titleHeroList: TitleContent
    private let content      : BodyContent
    
    init(
        _ imagePath       : String?,
        isImageClicked    : Binding<Bool> = .constant(false),
        colorPlaceholder  : Color  = .accentColor,
        iconPlaceholder   : String = "hanger",
        
        @ViewBuilder titleHeroList: () -> TitleContent,
        @ViewBuilder content      : () -> BodyContent
    ) {
        self.imagePath        = imagePath
        self._isImageClicked  = isImageClicked
        self.colorPlaceholder = colorPlaceholder
        self.iconPlaceholder  = iconPlaceholder
        self.titleHeroList    = titleHeroList()
        self.content          = content()
    }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 0) {
                self.heroImageSection
                
                LazyVStack(spacing: 24) {
                    content
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    @ViewBuilder
    private var heroImageSection: some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .global).minY
            let isScrollingDown = minY > 0
            
            AvatarView(
                imagePath,
                color: colorPlaceholder,
                icon: iconPlaceholder
            )
            .frame(
                width: proxy.size.width,
                height: proxy.size.height + (isScrollingDown ? minY : 0)
            )
            .offset(y: isScrollingDown ? -minY : 0)
        }
        .frame(height: 560)
        .clipped()
        .overlay(alignment: .bottom) {
            LinearGradient(
                stops: [
                    .init(color: Color(uiColor: .systemBackground), location: 0),
                    .init(color: Color(uiColor: .systemBackground).opacity(0.9), location: 0.2),
                    .init(color: Color(uiColor: .systemBackground).opacity(0.5), location: 0.5),
                    .init(color: Color(uiColor: .systemBackground).opacity(0.2), location: 0.8),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .bottom,
                endPoint  : .top
            )
            .frame(height: 300)
            .allowsHitTesting(false)
        }
        .overlay(alignment: .bottom) {
            titleHeroList
                .offset(y: -43)
        }
        .onTapGesture {
            self.isImageClicked = true
        }
        //        .overlay(alignment: .bottomTrailing) {
        //            Button(action: {}) {
        //                Image(systemName: "view.3d")
        //                    .font(.system(size: 18, weight: .semibold))
        //                    .foregroundStyle(.white)
        //                    .padding(12)
        //                    .background(.ultraThinMaterial)
        //                    .clipShape(Circle())
        //            }
        //            .padding(20)
        //        }
    }
}
