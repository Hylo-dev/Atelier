//
//  LaundrySession.swift
//  Atelier
//
//  Created by C4V4H.exe on 18/02/26.
//
import SwiftData
import Foundation

@Model
final class LaundrySession {
	@Attribute(.unique) var id: UUID
	
	var dateCreated: Date
	var status: LaundrySessionStatus
	
	// Relazione con i capi (definita nel tuo Garment.swift)
	@Relationship
	var garments: [Garment]
	
	// MARK: - Parametri Calcolati dall'Algoritmo
	var targetTemperature: Int
	var suggestedProgram: String
	var bin: LaundryBin
	
	var warnings: [String]
	
	init(bin: LaundryBin, garments: [Garment] = []) {
		self.id = UUID()
		self.dateCreated = .now
		self.status = .planned
		self.bin = bin
		self.garments = garments
		self.warnings = []
		
		// Valori temporanei, verranno sovrascritti subito da recalculateSettings()
		self.targetTemperature = 30
		self.suggestedProgram = "Standard"
		
		// Calcola subito i settaggi all'inizializzazione
		self.recalculateSettings()
	}
	
	// MARK: - L'Algoritmo (La funzione che chiedevi)
	/// Analizza i garments correnti e aggiorna temperatura e programma
	func recalculateSettings() {
		guard !garments.isEmpty else { return }
		
		var safeTemp = 90 // Partiamo alti e scendiamo
		var safeAgitation: WashingAgitation = .normal
		var newWarnings: [String] = []
		
		// 1. Iteriamo su tutti i capi della sessione
		for garment in garments {
			
			// --- Calcolo Temperatura ---
			// Trova la temp più bassa tra i simboli del capo (se non ne ha, assumiamo 40°C safe)
			let garmentMaxTemp = garment.washingSymbols
				.compactMap { $0.maxWashingTemperature }
				.min() ?? 40
			
			// Se questo capo vuole meno gradi del totale attuale, abbassiamo il totale
			if garmentMaxTemp < safeTemp {
				safeTemp = garmentMaxTemp
			}
			
			// --- Calcolo Agitazione (Delicatezza) ---
			// Se un capo richiede "Gentle", tutto il lavaggio diventa "Gentle"
			let levels = garment.washingSymbols.map { $0.agitationLevel }
			
			if levels.contains(.gentle) {
				safeAgitation = .gentle
			} else if levels.contains(.reduced) && safeAgitation == .normal {
				// Se siamo a Normal e troviamo un Reduced, scendiamo a Reduced
				// (ma se siamo già a Gentle, restiamo a Gentle)
				safeAgitation = .reduced
			}
			
			// --- Check Specifici per Avvisi ---
			// Esempio: Reggiseni o capi con ganci
			if garment.subCategory.rawValue == "Bra" || garment.subCategory.rawValue == "Underwear" { // Adatta con le tue stringhe rawValue corrette
				if !newWarnings.contains("Usa sacchetto a rete") {
					newWarnings.append("Usa sacchetto a rete")
				}
			}
		}
		
		// 2. Applichiamo i risultati alle proprietà del Modello
		self.targetTemperature = safeTemp
		self.warnings = newWarnings
		
		// Mappiamo l'enum Agitation in una Stringa leggibile per la UI
		switch safeAgitation {
		case .normal:
			self.suggestedProgram = "Cotone / Standard"
		case .reduced:
			self.suggestedProgram = "Sintetici / Mix"
		case .gentle:
			self.suggestedProgram = "Delicati / Lana"
		case .none:
			self.suggestedProgram = "Non Lavare!"
		}
	}
}

// Enum di supporto per lo stato della sessione
enum LaundrySessionStatus: String, Codable, CaseIterable {
	case planned   = "Pianificato"
	case washing   = "In Lavaggio"
	case drying    = "In Asciugatura"
	case completed = "Completato"
}
