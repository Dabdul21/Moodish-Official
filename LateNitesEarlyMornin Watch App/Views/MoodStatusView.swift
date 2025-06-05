//
//  MoodStatusView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/28/25.
//

import SwiftUI

struct MoodStatusView: View {
    
    @EnvironmentObject var healthManager: HealthManager
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var previousMood: Mood?
    @State private var currentChallengeIndex = 0
    @State private var challengeStreak = 0
    @State private var lastMoodChangeDate = Date()
    @State private var showManualMoodPicker = false
    @State private var manualMoodOverride: Mood?
    @State private var manualOverrideTimestamp: Date?
    @State private var isInitialLoad = true
    @AppStorage("totalChallengesCompleted") private var totalChallengesCompleted: Int = 0
    
    private let overrideExpirationTime: TimeInterval = 30 * 60
    
    var inferredMood: Mood {
        if let override = manualMoodOverride,
           let timestamp = manualOverrideTimestamp,
           Date().timeIntervalSince(timestamp) < overrideExpirationTime {
            return override
        } else if manualMoodOverride != nil {
            manualMoodOverride = nil
            manualOverrideTimestamp = nil
        }
        
        let mood = MoodEngine.inferMood(
            heartRate: healthManager.latestHeartRate,
            steps: healthManager.latestSteps,
            exerciseMinutes: healthManager.latestExerciseMinutes,
            sleepStage: healthManager.latestSleepStage
        )
        
        return mood
    }
    
    var hasHealthData: Bool {
        return healthManager.latestHeartRate > 0 ||
               healthManager.latestSteps > 0 ||
               healthManager.latestExerciseMinutes > 0 ||
               healthManager.latestSleepStage != "Unknown"
    }
    
    var isManualOverrideActive: Bool {
        guard let timestamp = manualOverrideTimestamp else { return false }
        return Date().timeIntervalSince(timestamp) < overrideExpirationTime
    }
    
    var textColor: Color {
        switch inferredMood {
        case .nervous, .happy, .tired:
            return .black
        default:
            return .white
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // MARK: - Main Mood Card + Challenge Button (grouped together)
                VStack(spacing: 9) {
                    // Main Mood Card
                    VStack(spacing: 10) {
                        Image(inferredMood.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 60)
                        
                        Text("Feeling \(inferredMood.label)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(textColor)
                        
                        if !inferredMood.challenges.isEmpty {
                            Text(inferredMood.challenges[currentChallengeIndex])
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(textColor.opacity(0.8))
                                .padding(.horizontal, 8)
                        }
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
                            .stroke(textColor.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Challenge Action Button
                    if !inferredMood.challenges.isEmpty {
                        Button(action: {
                            completeChallenge()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Challenge")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(textColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(inferredMood.color.opacity(0.9))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(textColor.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: inferredMood.color.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // MARK: - Stats Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Health Stats")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                    
                    VStack(spacing: 8) {
                        StatRow(icon: "heart.fill", label: "Heart Rate", value: healthManager.latestHeartRate > 0 ? "\(Int(healthManager.latestHeartRate)) BPM" : "No data", color: .red)
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
                    
                    if !inferredMood.challenges.isEmpty {
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
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                
                // MARK: - Manual Mood Change Section
                VStack(spacing: 10) {
                    if isManualOverrideActive {
                        HStack {
                            Text("Manual Override Active")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            
                            Spacer()
                            
                            if let timestamp = manualOverrideTimestamp {
                                let remainingMinutes = Int(overrideExpirationTime - Date().timeIntervalSince(timestamp)) / 60
                                Text("\(remainingMinutes) min left")
                                    .font(.caption2)
                                    .foregroundColor(.orange.opacity(0.8))
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Button("Reset to Auto") {
                                withAnimation {
                                    manualMoodOverride = nil
                                    manualOverrideTimestamp = nil
                                    currentChallengeIndex = 0
                                }
                            }
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.blue, lineWidth: 1)
                            )
                            
                            Button("Change Mood") {
                                showManualMoodPicker = true
                            }
                            .font(.caption2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.purple.opacity(0.6))
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button(action: {
                            showManualMoodPicker = true
                        }) {
                            HStack {
                                Image(systemName: "hand.point.up.fill")
                                Text("Correct My Mood")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.purple.opacity(0.6))
                            )
                        }
                        .buttonStyle(.plain)
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
            if !healthManager.healthKitAuthorized {
                healthManager.requestAuthorization()
            } else {
                healthManager.fetchAllHealthData()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                isInitialLoad = false
            }
        }
        .onChange(of: inferredMood) { oldValue, newValue in
            handleMoodChange(oldValue: oldValue, newValue: newValue)
        }
        .onChange(of: healthManager.latestHeartRate) { _, _ in
            print("DEBUG: Heart rate changed to \(healthManager.latestHeartRate)")
        }
        .onChange(of: healthManager.latestSteps) { _, _ in
            print("DEBUG: Steps changed to \(healthManager.latestSteps)")
        }
        .navigationDestination(isPresented: $showManualMoodPicker) {
            PickYourMoodView(selectedMood: manualMoodOverride ?? inferredMood) { newMood in
                withAnimation {
                    manualMoodOverride = newMood
                    manualOverrideTimestamp = Date()
                    currentChallengeIndex = 0
                    notificationManager.notifyMoodChange(to: newMood)
                    notificationManager.scheduleChallengeReminder(for: newMood)
                }
                showManualMoodPicker = false
            }
        }
    }
    
    private func handleMoodChange(oldValue: Mood?, newValue: Mood) {
        if let oldMood = oldValue, oldMood != newValue {
            let timeSinceLastChange = Date().timeIntervalSince(lastMoodChangeDate)
            
            if timeSinceLastChange > 300 {
                currentChallengeIndex = 0
                lastMoodChangeDate = Date()
                notificationManager.notifyMoodChange(to: newValue)
                notificationManager.scheduleChallengeReminder(for: newValue)
            }
        } else if oldValue == nil {
            lastMoodChangeDate = Date()
        }
        
        previousMood = newValue
    }
    
    private func completeChallenge() {
        totalChallengesCompleted += 1
        challengeStreak += 1
        
        if currentChallengeIndex < inferredMood.challenges.count - 1 {
            currentChallengeIndex += 1
        } else {
            currentChallengeIndex = 0
        }
        
        WKInterfaceDevice.current().play(.success)
    }
}

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
        .environmentObject(HealthManager())
        .environmentObject(NotificationManager.shared)
}
