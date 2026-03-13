//
//  SearchView.swift
//  Atelier
//
//  Created by C4V4H.exe on 12/03/26.
//

import SwiftUI
import SwiftData

enum ListRowItem: Identifiable, Hashable {
	case garment(Garment)
	case outfit (Outfit)
	case laundrySession(LaundrySession)
	
	var id: UUID {
		switch self {
		case .garment(let u): return u.id
		case .outfit(let m): return m.id
		case .laundrySession(let a): return a.id
		}
	}
	
	var name: String {
		switch self {
		case .garment(let g): return g.name
		case .outfit(let o): return o.name
		case .laundrySession(let l): return l.bin.displayName
		}
	}
	
	var image: String? {
		return switch self {
		case .garment(let g): g.imagePath
		case .outfit(let o) : o.fullLookImagePath
		case .laundrySession(_): nil
		}
	}
	
	@ViewBuilder
	var card: some View {
		
		Group {
			switch self {
			case .laundrySession(let session):
				let items: [Garment] = session.garments.filter {
					$0.imagePath != nil
				}
				
				MultipleCardView(
					title: session.bin.displayName,
					items: items
                )
                .equatable()
                    
			default:
				ModelCardView(
					title: name,
					imagePath: image
				)
                .equatable()
			}
		}
	}
}

struct SearchView: View {
	
	var title: String
	
	// MARK: - Search bar state
	@State
	private var searchText: String = ""
	
	// MARK: - Screen values
	@Query(
		sort : \Garment.id,
		order: .reverse
	)
	private var garments: [Garment]
	
	@Query(
		sort: \Outfit.id,
		order: .reverse
	)
	private var outfits: [Outfit]
	
	
	@Query(
		sort: \LaundrySession.id,
		order: .reverse
	)
	private var laundrySessions: [LaundrySession]
	
	
	var items: [ListRowItem] {
		let garmentsItems = garments.map { ListRowItem.garment($0) }
		let outfitsItems = outfits.map { ListRowItem.outfit($0) }
		let laundrySessionsItems = laundrySessions.map { ListRowItem.laundrySession($0) }
		
		// Unisco tutto e ordino per data (dal più recente)
		return (garmentsItems + outfitsItems + laundrySessionsItems).sorted { $0.name > $1.name }
	}
	
	
	private static let columns = [
		GridItem(
			.adaptive(minimum: 150),
			spacing: 20
		)
	]
	
	var body: some View {
		
		ScrollView {
			LazyVGrid (columns: Self.columns, spacing: 20) {
				ForEach(items, id: \.id) { item in
					NavigationLink(value: item) {
						item.card
					}
					.buttonStyle(.plain)
				}
			}
		}
		.navigationDestination(for: ListRowItem.self) { item in
			EmptyView()
		}
		.toolbar {
			ToolbarItem(placement: .title) {
				Text(String(repeating: " ", count: 90))
					.overlay(alignment: .leading) {
						Text(self.title)
							.font(.title)
							.fontWeight(.bold)
					}
			}
		}
		.searchable(text: $searchText)
	}
	
}
