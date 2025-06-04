//
//  ChallengeView.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 5/27/25.
//


    
    
import SwiftUI

struct ChallengeView: View {

    @State private var currentChallengeIndex = 0
    let mood: Mood // passed mood from another screen
 
    var body: some View {
        VStack(spacing: 20) {
            Text("Mood: \(mood.label)")
                .font(.headline)
                .foregroundColor(mood.color)

            Text(mood.challenges[currentChallengeIndex])
                .font(.title3)
                .padding()

            Button("Complete Challenge") {
                if currentChallengeIndex < mood.challenges.count - 1 {
                    currentChallengeIndex += 1
                } else {
                    currentChallengeIndex = 0 // Reset to first challenge
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Your Challenge")
    }
}


    
extension Mood {
    var challenges: [String] {
        switch self {
        case .overwhelmed:
            return [
                "Take deep breaths",
                "Do a quick stretch",
                "Write out your thoughts",
                "Make a short to-do list",
                "Step away from your screen for 5 minutes"
            ]
        case .happy:
            return [
                "Share your happiness",
                "Dance for 1 minute",
                "Write down what made you happy",
                "Send a kind message to someone",
                "Smile at yourself in the mirror"
            ]
        case .excited:
            return [
                "Channel your energy",
                "Plan your day",
                "Talk to a friend",
                "Write down your goals",
                "Celebrate your excitement with a song"
            ]
        case .calm:
            return [
                "Close your eyes for 1 min",
                "Listen to calm music",
                "Do deep breathing",
                "Sit in silence for 2 minutes",
                "Take a slow mindful walk"
            ]
        case .angry:
            return [
                "Take deep breaths",
                "Write your thoughts",
                "Go for a walk",
                "Squeeze a stress ball",
                "Listen to music that matches your mood"
            ]
        case .nervous:
            return [
                "Play a calming sound",
                "Take deep breaths",
                "Count backward from 30",
                "Write down what you're nervous about",
                "Stretch your hands and shoulders"
            ]
        case .sad:
            return [
                "Watch something funny",
                "Talk to someone",
                "Write how you feel",
                "Draw or doodle",
                "Wrap yourself in a blanket and rest"
            ]
        case .tired:
            return [
                "Stretch for 1 min",
                "Drink water",
                "Take a short break",
                "Do a quick face splash with cold water",
                "Turn off notifications for 10 minutes"
            ]
        }
    }
}

#Preview {
    // Preview using a single mood (e.g., .nervous)
    ChallengeView(mood: .calm)
}
