//
//  MoodStatusView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/28/25.
//

import SwiftUI

struct MoodStatusView: View {
    @StateObject private var healthManager = HealthManager()
    
    var inferredMood: Mood {
        MoodEngine.inferMood(
            heartRate: healthManager.latestHeartRate,
            steps: healthManager.latestSteps,
            exerciseMinutes: healthManager.latestExerciseMinutes,
            sleepStage: healthManager.latestSleepStage
        )
    }

    var body: some View {
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
            
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Heart Rate: \(Int(healthManager.latestHeartRate)) BPM")
//                Text("Steps: \(Int(healthManager.latestSteps))")
//                Text("Exercise: \(Int(healthManager.latestExerciseMinutes)) min")
//                Text("Sleep Stage: \(healthManager.latestSleepStage)")
//            }
            .font(.caption2)
            .multilineTextAlignment(.leading)
        }
        .padding()
        .onAppear {
            healthManager.requestAuthorization()
        }
    }
}
#Preview{
    MoodStatusView()
}
