//
//  ItemCareView.swift
//  Atelier
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 19/04/2026.
//

import SwiftUI

struct CareContextCardView: View {
    
    let item        : LaundrySession
    let manager     : LaundrySessionManaging
    var viewModel   : CareViewModel
    
    @State
    private var timeRemaining: TimeInterval = 0
    
    init(
        item     : LaundrySession,
        manager  : LaundrySessionManaging,
        viewModel: CareViewModel
    ) {
        self.item      = item
        self.manager   = manager
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        // TODO: When item status is `completed` change card UI
        NavigationLink(value: item) {
            MultipleCardView(
                title      : "\(item.targetTemperature)° \(item.suggestedProgram.displayName)",
                subheadline: item.subheadline,
                items      : item.garments
            )
            .equatable()
            .id(item.id)
        }
        .buttonStyle(.plain)
        .contextMenu { actionButton }
        .onReceive(manager.timerPulse) { _ in
            guard item.status == .washing else { return }
            
            updateTimeRemaining()
            if timeRemaining <= 0 {
                handleAutoFinish()
            }
        }
        .onAppear(perform: updateTimeRemaining)
        .onChange(of: item.status) { _, _ in
            updateTimeRemaining()
        }
    }
    
    
    // MARK: - Actions & Helpers
    
    private var actionButton: some View {
        Group {
            switch item.status {
                case .planned:
                    Button {
                        performAction(title: "Start Washing") {
                            try manager.startWashing(item)
                        }
                    } label: {
                        Label("Start Wash", systemImage: "play.fill")
                    }
                    
                case .washing:
                    Label(formatDuration(timeRemaining), systemImage: "timer")
                        .onAppear {
                            if timeRemaining == 0 { updateTimeRemaining() }
                        }
                    
                    Button {
                        performAction(title: "Pause Washing") {
                            try manager.pauseWashing(item)
                        }
                    } label: {
                        Label("Pause Wash", systemImage: "pause.fill")
                    }
                    
                    Divider()
                    
                    Button {
                        performAction(title: "Finish Washing") {
                            try manager.finishWashing(item)
                        }
                    } label: {
                        Label("Finish Wash", systemImage: "checkmark.circle")
                    }
                    
                    Button(role: .destructive) {
                        performAction(title: "Cancel Washing") {
                            try manager.cancelWashing(item)
                        }
                    } label: {
                        Label("Cancel Wash", systemImage: "xmark.circle")
                    }
                    
                case .clean:
                    Button {
                        performAction(title: "Start Drying") {
                            try manager.startDrying(item)
                        }
                    } label: {
                        Label("Start Drying", systemImage: "sun.max.fill")
                    }
                    
                case .paused:
                    Label(formatDuration(item.remainingTime ?? 0), systemImage: "pause.circle")
                    
                    Button {
                        performAction(title: "Resume Washing") {
                            try manager.resumeWashing(item)
                        }
                    } label: {
                        Label("Resume Wash", systemImage: "play.fill")
                    }
                    
                    Divider()
                    
                    Button {
                        performAction(title: "Finish Washing") {
                            try manager.finishWashing(item)
                        }
                    } label: {
                        Label("Finish Wash", systemImage: "checkmark.circle")
                    }
                    
                    Button(role: .destructive) {
                        performAction(title: "Cancel Washing") {
                            try manager.cancelWashing(item)
                        }
                    } label: {
                        Label("Cancel Wash", systemImage: "xmark.circle")
                    }
                    
                case .drying:
                    Button {
                        performAction(title: "Mark Complete") {
                            try manager.markAsComplete(item)
                        }
                    } label: {
                        Label("Mark as Done", systemImage: "checkmark.seal.fill")
                    }
                    
                    Button {
                        performAction(title: "Cancel Drying") {
                            try manager.cancelDrying(item)
                        }
                    } label: {
                        Label("Cancel Drying", systemImage: "xmark.circle")
                    }
                    
                default:
                    EmptyView()
            }
        }
    }
    
    private func handleAutoFinish() {
        performAction(title: "Finish Washing") {
            try manager.finishWashing(item)
        }
    }
    
    private func performAction(title: String, action: () throws -> Void) {
        do {
            try action()
        } catch {
            viewModel.alertManager.title     = title
            viewModel.alertManager.message   = error.localizedDescription
            viewModel.alertManager.isPresent = true
        }
    }
    
    private func updateTimeRemaining() {
        guard let endDate = item.completationDate else {
            timeRemaining = 0
            return
        }
        
        let remaining = endDate.timeIntervalSinceNow
        timeRemaining = max(0, remaining)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let interval = Int(seconds)
        let mins     = (interval % 3600) / 60
        let secs     = interval % 60
        
        return String(format: "%02d:%02d", mins, secs)
    }
}
