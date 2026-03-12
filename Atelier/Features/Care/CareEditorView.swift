//
//  CareEditorView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/03/26.
//

import SwiftUI

struct CareEditorView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    let item: LaundrySession?
    
    
    var body: some View {
        
        VStack {
            
        }
        .navigationTitle(
            item == nil ? "New Session" : "Edit Session"
        )
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") { dismiss() }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Finish", systemImage: "checkmark") {
//                    let garmentToProcess: Garment
//                    
//                    if self.item == nil {
//                        garmentToProcess = self.saveGarment()
//                        
//                    } else {
//                        
//                        self.updateGarment()
//                        garmentToProcess = item!
//                        applianceManager.unassignGarment(garmentToProcess)
//                    }
//                    
//                    applianceManager.processUnassignedGarments(
//                        [garmentToProcess],
//                        laundrySessions
//                    )
                    
                    dismiss()
                }
                .fontWeight(.bold)
                //.disabled(self.name.isEmpty)
            }
        }
//        .confirmationDialog(
//            "Choose Image",
//            isPresented: self.$showImageSourceDialog,
//            actions: confirmationDialogHandler,
//            message: { Text("Select how you want to add the photo") }
//        )
//        .sheet(
//            isPresented: self.$showCamera,
//            content    : sheetPhotoHandler
//        )
//        .sheet(
//            isPresented: self.$showScan,
//            content    : self.sheetScanHandler
//        )
//        .photosPicker(
//            isPresented: self.$showGalleryPicker,
//            selection  : self.$selectedItem,
//            matching   : .images
//        )
//        .onChange(
//            of: self.selectedFabrics,
//            selectedFabricsChanged
//        )
//        .onChange(of: self.selectedCategory) { _, newValue in
//            self.selectedSubCategory = newValue.subCategory.first ?? GarmentSubCategory.top
//        }
//        .onChange(
//            of: self.selectedItem,
//            self.selectedPhotoChanged
//        )
        
    }
}
