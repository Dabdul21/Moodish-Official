//
//  MoodCard.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/4/25.
//


//
//  MoodCard.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 6/4/25.
//

import SwiftUI

struct MoodCard: View {
    let mood: Mood
    let challenge: String
    let textColor: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(mood.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 60)
            
            Text("Feeling \(mood.label)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(textColor)
            
            if !challenge.isEmpty {
                Text(challenge)
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
                .fill(mood.color.gradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(textColor.opacity(0.3), lineWidth: 1)
        )
    }
}