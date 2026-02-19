//
//  Filter+SectionHeader.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 18/02/26.
//

import SwiftUI

enum FilterSectionHeader: String, CaseIterable, Identifiable {
    case main = "Options"
    var id: String { rawValue }
}

// MARK: - Conformance per GarmentCategory
extension GarmentCategory: SelectableItem {
    var category: FilterSectionHeader  { .main      }
    var title   : String               { self.label }
    var iconName: String?              { nil        }
}

// MARK: - Conformance per GarmentSubCategory
extension GarmentSubCategory: SelectableItem {

    var category: GarmentCategory {
        return GarmentCategory.allCases.first {
            $0.subCategory.contains(self)
        } ?? .top
    }
    
    var title   : String  { self.rawValue }
    var iconName: String? { nil           }
}

// MARK: - Conformance per Season
extension Season: SelectableItem {
    var category: FilterSectionHeader { .main         }
    var title   : String              { self.rawValue }
    var iconName: String? {
        return switch self {
            case .summer    : "sun.max.fill"
            case .winter    : "snowflake"
            case .spring    : "leaf.fill"
            case .seasonLess: "sparkles"
        }
    }
}

// MARK: - Conformance per GarmentStyle
extension GarmentStyle: SelectableItem {
    var category: FilterSectionHeader { .main         }
    var title   : String              { self.rawValue }
    var iconName: String?             { nil           }
}

// MARK: - Conformance per GarmentState
extension GarmentState: SelectableItem {
    var category: FilterSectionHeader { .main         }
    var title   : String              { self.rawValue }
    var iconName: String?             { nil           }
}
