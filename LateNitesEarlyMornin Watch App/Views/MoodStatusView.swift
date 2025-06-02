//
//  MoodStatusView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/28/25.
//

import SwiftUI

struct MoodStatusView: View {
    @StateObject private var healthManager = HealthManager()
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var previousMood: Mood?
    
    var inferredMood: Mood {
        MoodEngine.inferMood(
            heartRate: healthManager.latestHeartRate,
            steps: healthManager.latestSteps,
            exerciseMinutes: healthManager.latestExerciseMinutes,
            sleepStage: healthManager.latestSleepStage
        )
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 12) {
                //            Text("How do you feel?")
                //                .font(.headline)
                //                .padding(.top, 0)
                
                
                Image(inferredMood.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                
                Text(inferredMood.label)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                
                Divider()
                    .background(Color.gray)
                
                //testingg stats they work so far
                //make sure you test it more when u are wearing the watch more they should be chaning live it just takes a lil while since healthkit does it in batches and not every singular step is counted but every few min
                
            VStack(alignment: .leading, spacing: 4) {
                Text("Heart Rate: \(Int(healthManager.latestHeartRate)) BPM")
                Text("Steps: \(Int(healthManager.latestSteps))")
                Text("Exercise: \(Int(healthManager.latestExerciseMinutes)) min")
                Text("Sleep Stage: \(healthManager.latestSleepStage)")
            }
            .font(.caption2)
            .multilineTextAlignment(.leading)
                
            }
            .padding()
            .onAppear {
                healthManager.requestAuthorization()
            }
            .onChange(of: inferredMood) { oldValue, newValue in
                // Only send notification if mood actually changed and we have a previous mood
                if let previous = previousMood, previous != newValue {
                    notificationManager.notifyMoodChange(to: newValue)
                    notificationManager.scheduleChallengeReminder(for: newValue)
                }
                previousMood = newValue
            }
        }
    }
}
#Preview{
    MoodStatusView()
        .environmentObject(NotificationManager.shared)
}
