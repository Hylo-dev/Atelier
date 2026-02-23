//
//  fuori.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 23/02/26.
//

import Foundation

struct TabFilterState {
    var items    : [String] = ["All"]
    var selection: String?  = "All"
    var progress : CGFloat  = .zero
    
    var isVisible: Bool {
        return items.count > 2
    }
}
