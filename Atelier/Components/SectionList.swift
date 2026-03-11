//
//  Section.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 08/03/26.
//

import SwiftUI

struct SectionList<Content: View>: View {
    
    let titleKey: any StringProtocol
    
    @ViewBuilder
    let content: Content
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text(self.titleKey)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.leading, 16)
            
            VStack(spacing: 0) {
                
                Group(subviews: self.content) { subViews in
                    let count = subViews.count
                    
                    ForEach(0..<count, id: \.self) { index in
                        let view = subViews[index]
                        
                        view
                            .frame(minHeight: 44)
                            .id(view.id)
                        
                        if index < count - 1 {
                            Divider()
                        }
                    }
                    
                    
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 3)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        }
    }
}
