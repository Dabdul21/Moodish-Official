//
//  MoodComponents.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 6/4/25.
//

import SwiftUI

// MARK: - Mini Mood Timeline Component
struct MiniMoodTimeline: View {
    let recentMoods: [Mood]
    
    var body: some View {
        HStack(spacing: 4) {
            Text("Recent:")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 6) {
                ForEach(Array(recentMoods.enumerated()), id: \.offset) { index, mood in
                    Circle()
                        .fill(mood.color)
                        .frame(width: index == 0 ? 12 : 8, height: index == 0 ? 12 : 8)
                        .opacity(index == 0 ? 1.0 : 0.7)
                }
                
                // Fill remaining circles if less than 5 moods
                ForEach(recentMoods.count..<5, id: \.self) { _ in
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

// MARK: - Streak Warning Component
struct StreakWarning: View {
    let challengeStreak: Int
    let currentChallengeIndex: Int
    
    var body: some View {
        if challengeStreak > 0 && currentChallengeIndex == 0 {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.caption2)
                
                Text("Complete a challenge to keep your \(challengeStreak)-day streak!")
                    .font(.caption2)
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.orange.opacity(0.2))
            )
        }
    }
}

// MARK: - Log Mood Button Component
struct LogMoodButton: View {
    let mood: Mood
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Log This Mood", systemImage: "square.and.pencil")
                .font(.caption)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(mood.color.opacity(0.7))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Settings Toggle Component
struct SettingsToggle: View {
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
            
            Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}