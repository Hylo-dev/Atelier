//
//  ApplianceManager.swift
//  Atelier
//
//  Created by C4V4H.exe on 18/02/26.
//
import Observation
import SwiftData
import Foundation

@Observable
@MainActor
final class ApplianceManager {
    static let shared = ApplianceManager()
    
    // Keys per UserDefaults
    private let kCycleCount = "washingMachineCycleCount"
    
    var cyclesSinceLastClean: Int {
        get { UserDefaults.standard.integer(forKey: kCycleCount) }
        set { UserDefaults.standard.set(newValue, forKey: kCycleCount) }
    }
    
    func registerCycle() {
        var current = cyclesSinceLastClean
        current += 1
        cyclesSinceLastClean = current
    }
    
    var needsCleaning: Bool {
        return cyclesSinceLastClean >= 30
    }
	
	func resetCycles() {
		cyclesSinceLastClean = 0;
	}
    
    func resetCleaningStatus() {
        cyclesSinceLastClean = 0
    }
}
