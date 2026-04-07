//
//  ImageSaveError.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 07/04/2026.
//


enum ImageSaveError: Error {
    case conversionFailed
    case folderNotFound
    case writeFailed(String)
    
    var localizedDescription: String {
        return switch self {
            case .conversionFailed:
                "We couldn't process this photo. Please try taking it again."
                
            case .folderNotFound:
                "Something went wrong while accessing your phone's storage. Please restart the app."
                
            case .writeFailed(let details):
                
                if details.contains("out of space") {
                    "Your iPhone storage is full. Please make some space to save new items."

                } else {
                    "The photo couldn't be saved. Please try again in a moment."
                }
                
        }
    }
}