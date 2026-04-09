//
//  GarmentGroupActor.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 09/04/2026.
//

import SwiftData

actor GroupActor {
    
    func computeGroups(
        from garments: [DTO]
    ) -> GroupedResult {
        
        let groupedByCategory = Dictionary(
            grouping: garments,
            by      : { $0.secondLabel }
        )
        
        var groupedIDs: [String: [PersistentIdentifier]] = [:]
        for (category, items) in groupedByCategory {
            groupedIDs[category] = items.map { $0.id }
        }
        
        let brands = Array(
            Set(garments.compactMap { $0.firstLabel })
        ).sorted()
        
        let tags = ["All"] + Array(
            Set(garments.map { $0.secondLabel })
        ).sorted()
        
        return GroupedResult(
            brands    : brands,
            tags      : tags,
            groupedIDs: groupedIDs
        )
    }
}
