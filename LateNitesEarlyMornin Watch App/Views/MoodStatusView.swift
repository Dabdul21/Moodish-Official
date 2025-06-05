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
        
        return MoodEngine.inferMood(
            heartRate: healthManager.latestHeartRate,
            steps: healthManager.latestSteps,
            exerciseMinutes: healthManager.latestExerciseMinutes,
            sleepStage: healthManager.latestSleepStage
        )
    }
    
    var textColor: Color {
        switch inferredMood {
        case .nervous, .happy, .tired: return .black
        default: return .white
        }
    }
    
    var isManualOverrideActive: Bool {
        guard let timestamp = manualOverrideTimestamp else { return false }
        return Date().timeIntervalSince(timestamp) < overrideExpirationTime
    }
    
    var remainingMinutes: Int {
        guard let timestamp = manualOverrideTimestamp else { return 0 }
        return Int(overrideExpirationTime - Date().timeIntervalSince(timestamp)) / 60
    }
    
    var currentChallenge: String {
        guard !inferredMood.challenges.isEmpty else { return "" }
        return inferredMood.challenges[currentChallengeIndex]
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 9) {
                    MoodCard(mood: inferredMood, challenge: currentChallenge, textColor: textColor)
                    
                    if !inferredMood.challenges.isEmpty {
                        ChallengeButton(mood: inferredMood, textColor: textColor) {
                            completeChallenge()
                        }
                    }
                }
                
                HealthStatsSection()
                
                ChallengeProgressSection(
                    mood: inferredMood,
                    currentIndex: currentChallengeIndex,
                    totalCompleted: totalChallengesCompleted,
                    streak: challengeStreak
                )
                
                ManualMoodSection(
                    isActive: isManualOverrideActive,
                    remainingMinutes: remainingMinutes,
                    onReset: resetToAuto,
                    onChange: { showManualMoodPicker = true }
                )
                
                Spacer(minLength: 20)
            }
            .padding()
        }
        .onAppear {
            setupInitialState()
        }
        .onChange(of: inferredMood) { oldValue, newValue in
            handleMoodChange(oldValue: oldValue, newValue: newValue)
        }
        .navigationDestination(isPresented: $showManualMoodPicker) {
            PickYourMoodView(selectedMood: manualMoodOverride ?? inferredMood) { newMood in
                setManualMoodOverride(newMood)
                showManualMoodPicker = false
            }
        }
    }
    
    private func setupInitialState() {
        if !healthManager.healthKitAuthorized {
            healthManager.requestAuthorization()
        } else {
            healthManager.fetchAllHealthData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            isInitialLoad = false
        }
    }
    
    private func resetToAuto() {
        withAnimation {
            manualMoodOverride = nil
            manualOverrideTimestamp = nil
            currentChallengeIndex = 0
        }
    }
    
    private func setManualMoodOverride(_ mood: Mood) {
        withAnimation {
            manualMoodOverride = mood
            manualOverrideTimestamp = Date()
            currentChallengeIndex = 0
            notificationManager.notifyMoodChange(to: mood)
            notificationManager.scheduleChallengeReminder(for: mood)
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

#Preview {
    MoodStatusView()
        .environmentObject(HealthManager())
        .environmentObject(NotificationManager.shared)
}
