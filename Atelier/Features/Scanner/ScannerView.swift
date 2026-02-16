import SwiftUI

struct ScannerView: View {    
    @Bindable
    var manager: CaptureManager
    
    var body: some View {
#if os(iOS) || os(ipadOS)
        ZStack {
            
            CameraView(captureManager: manager)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Circle()
                    .fill(manager.multipeer.isConnected ? .green : .red)
                    .frame(width: 10, height: 10)
               
                Text(manager.multipeer.isConnected ? "Mac Connesso" : "Cercando Mac...")
                    .font(.caption)
                    .foregroundColor(.white)
                }
                .padding(8)
                .background(.black.opacity(0.6))
                .cornerRadius(20)
                .padding(.top, 50)
                
                Spacer()
                
                if manager.capturedPhotoURLs.count > 0 {
                    Button(action: { manager.sendAllPhotosToMac() }) {
                        VStack(alignment: .trailing) {
                            Text("3D")
                                .font(.headline)
                            
                            Text("\(manager.capturedPhotoURLs.count) foto pronte")
                                .font(.caption)
                        }
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(manager.multipeer.isConnected ? Color.yellow : Color.gray)
                        .cornerRadius(15)
                    }
                    .disabled(!manager.multipeer.isConnected)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            
        }
#endif
    }

}
