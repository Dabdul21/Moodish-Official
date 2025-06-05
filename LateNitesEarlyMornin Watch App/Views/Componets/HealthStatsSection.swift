//
//  HealthStatsSection.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/4/25.
//


//
//  HealthStatsSection.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 6/4/25.
//

import SwiftUI

struct HealthStatsSection: View {
    @EnvironmentObject var healthManager: HealthManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health Stats")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
            
            VStack(spacing: 8) {
                StatRow(
                    icon: "heart.fill", 
                    label: "Heart Rate", 
                    value: healthManager.latestHeartRate > 0 ? "\(Int(healthManager.latestHeartRate)) BPM" : "No data", 
                    color: .red
                )
                StatRow(
                    icon: "figure.walk", 
                    label: "Steps", 
                    value: "\(Int(healthManager.latestSteps))", 
                    color: .green
                )
                StatRow(
                    icon: "figure.run", 
                    label: "Exercise", 
                    value: "\(Int(healthManager.latestExerciseMinutes)) min", 
                    color: .blue
                )
                StatRow(
                    icon: "bed.double.fill", 
                    label: "Sleep Stage", 
                    value: healthManager.latestSleepStage, 
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}