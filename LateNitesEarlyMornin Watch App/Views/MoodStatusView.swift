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
    @State private var currentChallengeIndex = 0
    @State private var challengeStreak = 0
    @AppStorage("totalChallengesCompleted") private var totalChallengesCompleted: Int = 0
    
    var inferredMood: Mood {
        MoodEngine.inferMood(
            heartRate: healthManager.latestHeartRate,
            steps: healthManager.latestSteps,
            exerciseMinutes: healthManager.latestExerciseMinutes,
            sleepStage: healthManager.latestSleepStage
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Main Mood Card
                VStack(spacing: 10) {
                    Image(inferredMood.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 60)
                    
                    Text("Feeling \(inferredMood.label)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(inferredMood.challenges[currentChallengeIndex])
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(inferredMood.color.gradient)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                
                // MARK: - Challenge Action Button
                Button(action: {
                    completeChallenge()
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Complete Challenge")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
//                    .padding(.horizontal, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(inferredMood.color.opacity(0.8))
                    )
                }
                .buttonStyle(.plain)
                
                // MARK: - Stats Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Health Stats")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    VStack(spacing: 8) {
                        StatRow(icon: "heart.fill", label: "Heart Rate", value: "\(Int(healthManager.latestHeartRate)) BPM", color: .red)
                        StatRow(icon: "figure.walk", label: "Steps", value: "\(Int(healthManager.latestSteps))", color: .green)
                        StatRow(icon: "figure.run", label: "Exercise", value: "\(Int(healthManager.latestExerciseMinutes)) min", color: .blue)
                        StatRow(icon: "bed.double.fill", label: "Sleep Stage", value: healthManager.latestSleepStage, color: .purple)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                
                // MARK: - Challenge Progress Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Challenge Progress")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(totalChallengesCompleted)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Total Completed")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(challengeStreak)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("Current Streak")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    // Progress indicator for current mood challenges
                    HStack {
                        ForEach(0..<inferredMood.challenges.count, id: \.self) { index in
                            Circle()
                                .fill(index <= currentChallengeIndex ? inferredMood.color : .white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                        Spacer()
                        Text("\(currentChallengeIndex + 1) of \(inferredMood.challenges.count)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .onAppear {
            healthManager.requestAuthorization()
        }
        .onChange(of: inferredMood) { oldValue, newValue in
            // Reset challenge index when mood changes
            if oldValue != newValue {
                currentChallengeIndex = 0
                
                // Only send notification if mood actually changed and we have a previous mood
                if let previous = previousMood, previous != newValue {
                    notificationManager.notifyMoodChange(to: newValue)
                    notificationManager.scheduleChallengeReminder(for: newValue)
                }
            }
            previousMood = newValue
        }
    }
    
    // MARK: - Helper Functions
    private func completeChallenge() {
        // Increment total challenges completed
        totalChallengesCompleted += 1
        challengeStreak += 1
        
        // Move to next challenge or cycle back to first
        if currentChallengeIndex < inferredMood.challenges.count - 1 {
            currentChallengeIndex += 1
        } else {
            currentChallengeIndex = 0
        }
        
        // Haptic feedback
        WKInterfaceDevice.current().play(.success)
    }
}

// MARK: - StatRow Component
struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    MoodStatusView()
        .environmentObject(NotificationManager.shared)
}
