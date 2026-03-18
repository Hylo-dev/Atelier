//
//  AtelierWidgetsLiveActivity.swift
//  AtelierWidgets
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 16/03/26.
//

import WidgetKit
import SwiftUI
import AppIntents

struct AtelierWidgetsLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: LaundryAttributes.self) { context in
            // Lock screen banner
            HStack {
                
                HStack {
                    Button(intent: ToggleLaundryIntent(sessionID: context.attributes.sessionID)) {
                        Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
                    }
                    .buttonStyle(.automatic)
                    .buttonBorderShape(.circle)
                    .font(.title)
                    
                    Button(intent: CancelLaundryIntent(sessionID: context.attributes.sessionID)) {
                        Image(systemName: "stop.fill")
                    }
                    .buttonStyle(.automatic)
                    .buttonBorderShape(.circle)
                    .tint(.secondary)
                    .font(.title)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 10)
                
                Group {
                    if context.state.isPaused, let timeLeft = context.state.pausedTimeLeft {
                        Text(formatTime(timeLeft))
                        
                    } else {
                        Text(
                            timerInterval: context.state.interval,
                            countsDown: true
                        )
                    }
                }
                .monospacedDigit()
                .fontWeight(.semibold)
                .font(.title)
                .multilineTextAlignment(.trailing)
                
            }
            .frame(maxWidth: .infinity)
            .padding()
            
        } dynamicIsland: { context in
            DynamicIsland {
                // AREA SINISTRA
                DynamicIslandExpandedRegion(.leading) {
                    
                    VStack(alignment: .leading, spacing: 3) {
                        
                        Group {
                            if context.state.isPaused, let timeLeft = context.state.pausedTimeLeft {
                                Text(formatTimeMinutes(timeLeft))
                                
                            } else {
                                Text(
                                    timerInterval: context.state.interval,
                                    countsDown: true,
                                    showsHours: false
                                )
                            }
                        }
                        .monospacedDigit()
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(height: 24, alignment: .leading)
                        
                                                
                        Text("\(context.attributes.programName) • \(context.attributes.temperature)°")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        
                    }
                    .padding(.top, 8)
                    .padding(.leading, 8)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 8) {
                        
                        if !context.isStale {
                            Button(intent: ToggleLaundryIntent(sessionID: context.attributes.sessionID)) {
                                Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
                            }
                            .buttonStyle(.automatic)
                            .buttonBorderShape(.circle)
                            .font(.title)
                        }
                        
                        
                        Group {
                            if context.isStale {
                                Button(intent: CancelLaundryIntent(sessionID: context.attributes.sessionID)) {
                                    Image(systemName: "checkmark")
                                }
                                
                            } else {
                                Button(intent: CancelLaundryIntent(sessionID: context.attributes.sessionID)) {
                                    Image(systemName: "stop.fill")
                                }
                            }
                        }
                        .buttonStyle(.automatic)
                        .buttonBorderShape(.circle)
                        .tint(.secondary)
                        .font(.title)
                        
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                }
                
                // AREA INFERIORE
                DynamicIslandExpandedRegion(.bottom) {
                    
                    Group {
                        if context.state.isPaused {
                            ProgressView(
                                value: context.state.pausedProgress,
                                total: 1.0
                            )
                            
                        } else {
                            ProgressView(
                                timerInterval: context.state.interval,
                                countsDown: true
                            )
                        }
                    }
                    .frame(height: 12)
                    .progressViewStyle(.linear)
                    .tint(.accentColor)
                    .labelsHidden()
                    .scaleEffect(x: 1, y: 1.6, anchor: .center)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                                        
                }
                
            } compactLeading: {
                
                Group {
                    if context.state.isPaused || context.isStale {
                        ProgressView(value: context.state.pausedProgress, total: 1.0) {
                            Image(systemName: "washer.fill")
                                .foregroundStyle(.tint)
                        }
                        
                    } else {
                        ProgressView(
                            timerInterval: context.state.interval,
                            countsDown: true,
                            label: { EmptyView() }
                        ) {
                            Image(systemName: "washer.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .progressViewStyle(.circular)
                .tint(.accentColor)
                
                
            } compactTrailing: {
                
                Group {
                    if context.isStale {
                        Text("Fine")
                        
                    } else if context.state.isPaused, let timeLeft = context.state.pausedTimeLeft {
                        Text(formatTime(timeLeft))
                            
                        
                    } else {
                        Text(
                            timerInterval: context.state.interval,
                            countsDown: true
                        )
                    }
                }
                .frame(minWidth: 40, maxWidth: 100)
                .font(.caption)
                .fontWeight(.bold)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.tint)
                .padding(.trailing, 5)
                
                
                
            } minimal: {
                Group {
                    if context.state.isPaused {
                        ProgressView(value: context.state.pausedProgress, total: 1.0) {
                            Image(systemName: "washer.fill")
                                .foregroundStyle(.tint)
                        }
                        
                    } else {
                        ProgressView(
                            timerInterval: context.state.interval,
                            countsDown: true,
                            label: { EmptyView() }
                        ) {
                            Image(systemName: "washer.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .progressViewStyle(.circular)
                .tint(.accentColor)
            }
        }
    }
    
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(ceil(seconds))
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        
        return String(format: "%d:%02d:%02d", h, m, s)
    }
    
    func formatTimeMinutes(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(ceil(seconds))
        
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        
        return String(format: "%02d:%02d", m, s)
    }
}
