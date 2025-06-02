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
            return ["Take deep breaths", "Do a quick stretch", "Write out your thoughts"]
        case .happy:
            return ["Share your happiness", "Dance for 1 minute", "Write down what made you happy"]
        case .excited:
            return ["Channel your energy", "Plan your day", "Talk to a friend"]
        case .calm:
            return ["Close your eyes for 1 min", "Listen to calm music", "Do deep breathing"]
        case .angry:
            return ["Take deep breaths", "Write your thoughts", "Go for a walk"]
        case .nervous:
            return ["Play a calming sound", "Take deep breaths", "Count backward from 30"]
        case .sad:
            return ["Watch something funny", "Talk to someone", "Write how you feel"]
        case .tired:
            return ["Stretch for 1 min", "Drink water", "Take a short break"]
        }
    }
}

#Preview {
    // Preview using a single mood (e.g., .nervous)
    ChallengeView(mood: .calm)
}
