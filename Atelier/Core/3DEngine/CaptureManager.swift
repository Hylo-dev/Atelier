import Foundation
import RealityKit
import Observation
import SwiftUI

@Observable
final class CaptureManager {
    var multipeer: MultipeerManager = MultipeerManager()
    
    var isProcessing: Bool = false
    var processingProgress: Double = 0.0
    var readyToProcess: Bool = false
    
    private let fileManager = FileManager.default
    
    var capturedPhotoURLs: [URL] = []
    private var scanInputFolder: URL?
    
    // MARK: - Init logic
    
    init() {
        #if os(macOS)
        setupPaths()
        #endif
        
        setupHandlers()
    }
    
    private func setupPaths() {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.scanInputFolder = docs.appendingPathComponent("Atelier_Scans/Input", isDirectory: true)
        try? fileManager.createDirectory(at: self.scanInputFolder!, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func setupHandlers() {
        #if os(macOS)
        self.multipeer.onFileReceived = { [weak self] tempURL in self?.moveReceivedFileToProjectFolder(tempURL) }
        #endif

        self.multipeer.onDataReceived = { [weak self] data in
            guard let self = self else { return }
                
            if let msg = String(data: data, encoding: .utf8), msg == "END_BATCH" {
                print("Mac: Received all images, thx!.")
                    
                Task { @MainActor in self.readyToProcess = true }
            }
        }
    }
    
    // MARK: - iOS Logic
    #if os(iOS)
    func savePhotoToDisk(_ photoData: Data) -> (
        filename: String?,
        image   : UIImage?
    ) {
        let filename = "\(UUID().uuidString).heic"
        
        let paths = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        let fileURL = paths[0].appendingPathComponent(filename)
        
        do {
            try photoData.write(to: fileURL)
            
            let image = UIImage(data: photoData)
            return (filename, image)
            
        } catch {
            print("Error save image: \(error)")
            return (nil, nil)
        }
    }
    
    func sendAllPhotosToMac() {
        guard self.multipeer.isConnected else { return }
        print("Send \(self.capturedPhotoURLs.count) photo.")
        
        // Invio sequenziale dei file
        for url in self.capturedPhotoURLs {
            self.multipeer.sendResource(at: url)
        }
        
        // Segnale di fine
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.multipeer.send(msg: "END_BATCH")
        }
        
        self.capturedPhotoURLs.removeAll()
    }
    
    #elseif os(macOS)
    // MARK: - macOS Logic
    
    private var modelsOutputFolder: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir  = docs.appendingPathComponent("Atelier_Models", isDirectory: true)
        
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        
        return dir
    }

    private func moveReceivedFileToProjectFolder(_ tempURL: URL) {
        guard let folder = scanInputFolder else { return }
        let destination = folder.appendingPathComponent(UUID().uuidString + ".heic")
            
        do {
            // If exist file, remove file
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            
            try fileManager.moveItem(at: tempURL, to: destination)
            print("Saved photo: \(destination.lastPathComponent)")
            
        } catch {
            print("Error on move file: \(error)")
        }
    }
    
    @MainActor
    func startReconstruction() async {
        guard let inputFolder = scanInputFolder else { return }
        
        let files = try? fileManager.contentsOfDirectory(
            at: inputFolder,
            includingPropertiesForKeys: [.fileSizeKey]
        )
        
        let count = files?.count ?? 0
        
        if count < 10 {
            print("More photos (\(count)). Need 10-20 photos for create model")
            return
        }

        self.isProcessing       = true
        self.processingProgress = 0.0
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let outputURL = modelsOutputFolder.appendingPathComponent("Garment_\(formatter.string(from: Date())).usdz")
        
        do {
            let session = try PhotogrammetrySession(input: inputFolder)
            
            // Use full for quality
            try session.process(requests: [.modelFile(url: outputURL, detail: .full)])
            
            for try await output in session.outputs {
                switch output {
                    case .requestProgress(_, let fraction):
                        self.processingProgress = fraction
                        
                    case .processingComplete:
                        if self.isProcessing {
                            self.isProcessing = false
                            // NSWorkspace.shared.selectFile(outputURL.path, inFileViewerRootedAtPath: "")
                            
                            print("Saved model correctly: \(outputURL.path)")
                        }
                        
                    case .requestError(_, let error):
                        self.isProcessing = false
                        print("Error photogrammetry: \(error)")
                        return
                        
                    case .inputComplete:
                        print("Input finished, start generation mesh.")
                        
                    default: break
                }
            }
        } catch {
            print("Error init session: \(error)")
            self.isProcessing = false
        }
    }
    
    #endif
}
