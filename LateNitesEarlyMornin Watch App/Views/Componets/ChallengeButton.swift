//
//  ChallengeButton.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/4/25.
//


//
//  ChallengeButton.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 6/4/25.
//

import SwiftUI

struct ChallengeButton: View {
    let mood: Mood
    let textColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
                    .fill(mood.color.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(textColor.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: mood.color.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}