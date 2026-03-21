//
//  CameraContainerView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/03/26.
//


import SwiftUI

struct CameraContainerView: View {
    @Environment(\.dismiss)
    var dismiss
    
    
    
    @State
    private var isFlashEnabled = false
    
    @State
    private var isUsingFrontCamera = false
    
    @State
    private var showGallery = false
    
    @State
    private var triggerCapture = false
    
    @State
    private var containerSize: CGSize = .zero
    
    
    
    let mode: CameraMode
    
    var onSymbolsCaptured: (([String]) -> Void)?
    var onImageCaptured  : ((String, UIImage) -> Void)
    
    
    
    init(
        mode             : CameraMode = .photo(removeBackground: false),
        onSymbolsCaptured: (([String]) -> Void)? = nil,
        onImageCaptured  : @escaping ((String, UIImage) -> Void)
    ) {
        self.mode              = mode
        self.onSymbolsCaptured = onSymbolsCaptured
        self.onImageCaptured   = onImageCaptured
    }
    
    var body: some View {
        CameraView(
            isFlashEnabled     : $isFlashEnabled,
            isUsingFrontCamera : $isUsingFrontCamera,
            capturePhotoTrigger: $triggerCapture,
            onImageCaptured    : onImageCaptured,
            onSymbolsCaptured  : onSymbolsCaptured,
            mode               : mode
        )
        .ignoresSafeArea()
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: {
            containerSize = $1
        }
        .overlay {
            if containerSize != .zero {
                let viewfinderW = containerSize.width
                let viewfinderH = viewfinderW * 1.5
                
                let topOffset: CGFloat = 70
                
                Color.black
                    .opacity(0.8)
                    .mask {
                        ZStack(alignment: .top) {
                            Rectangle()
                            
                            Rectangle()
                                .frame(width: viewfinderW, height: viewfinderH)
                                .padding(.top, topOffset)
                                .blendMode(.destinationOut)
                        }
                    }
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .navigationTitle("Take Photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
                        
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { isFlashEnabled.toggle() }) {
                    Image(systemName: isFlashEnabled ? "bolt.fill" : "bolt.slash.fill")
                        .foregroundColor(
                            isFlashEnabled ? .yellow : .white
                        )
                }
            }
        }
        .overlay(alignment: .bottom) {
            HStack {
                Button(
                    "Gallery",
                    systemImage: "photo.on.rectangle"
                ) {
                    showGallery = true
                }
                .font(.title2)
                .labelStyle(.iconOnly)
                .controlSize(.large)
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
                
                Spacer()
                
                Button(action: {
                    triggerCapture = true
                }) {
                    
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial.opacity(0.8))
                            .glassEffect(in: .circle)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(.white.opacity(0.8))
                            .frame(width: 70, height: 70)
                    }
                    
                    
                }
                
                Spacer()
                
                Button(
                    "Rotate Camera",
                    systemImage: "camera.rotate"
                ) {
                    isUsingFrontCamera.toggle()
                }
                .font(.title2)
                .labelStyle(.iconOnly)
                .controlSize(.large)
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
        }
    }
}
