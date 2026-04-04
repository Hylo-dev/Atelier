//
//  HeroListView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/03/26.
//

import SwiftUI

struct HeroListView<TitleContent: View, BodyContent: View>: View {
    
    private let imagePath       : String?
    private let previewImage    : UIImage?
    
    @Binding
    private var isImageClicked  : Bool
    
    private let colorPlaceholder: [Color]
    private let placeholderGradient: Bool
    private let iconPlaceholder : String
    
    private let titleHeroList: TitleContent
    private let content      : BodyContent
    
    init(
        _ imagePath        : String?,
        previewImage       : UIImage?      = nil,
        isImageClicked     : Binding<Bool> = .constant(false),
        colorPlaceholder   : [Color]       = [.accentColor],
        placeholderGradient: Bool          = false,
        iconPlaceholder    : String        = "hanger",
        
        @ViewBuilder titleHeroList: () -> TitleContent,
        @ViewBuilder content      : () -> BodyContent
    ) {
        self.imagePath           = imagePath
        self.previewImage        = previewImage
        self._isImageClicked     = isImageClicked
        self.colorPlaceholder    = colorPlaceholder
        self.placeholderGradient = placeholderGradient
        self.iconPlaceholder     = iconPlaceholder
        self.titleHeroList       = titleHeroList()
        self.content             = content()
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
        AvatarView(
            imagePath,
            color   : colorPlaceholder,
            gradient: placeholderGradient,
            icon    : iconPlaceholder,
            uiImage : previewImage
        )
        .frame(height: 700)
        .visualEffect { content, proxy in
            let minY = proxy.frame(in: .global).minY
            let isScrollingDown = minY > 0
            
            let scale = isScrollingDown ? 1.0 + (minY / proxy.size.height) : 1.0
            
            return content
                .scaleEffect(
                    x: scale,
                    y: scale,
                    anchor: .bottom
                )
        }
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color(uiColor: .systemBackground),
                    Color(uiColor: .systemBackground).opacity(0.8),
                    Color(uiColor: .systemBackground).opacity(0.4),
                    Color(uiColor: .systemBackground).opacity(0.1),
                    .clear
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
