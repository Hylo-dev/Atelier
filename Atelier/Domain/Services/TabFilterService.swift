//
//  fuori.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 23/02/26.
//

import Foundation

@Observable
final class TabFilterService {
    var items           : [String] = ["All"]
    var selection       : String?  = "All"
    var progress        : CGFloat  = .zero
    var hiddenSectionBar: Bool     = false
    
    var isPagesEnabled: Bool {
        items.count > 2
    }
    
    var isToolbarEnabled: Bool {
        isPagesEnabled && !hiddenSectionBar
    }
}
