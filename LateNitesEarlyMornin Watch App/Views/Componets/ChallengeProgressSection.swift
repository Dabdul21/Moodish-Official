//
//  ChallengeProgressSection.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/4/25.
//


//
//  ChallengeProgressSection.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 6/4/25.
//

import SwiftUI

struct ChallengeProgressSection: View {
    let mood: Mood
    let currentIndex: Int
    let totalCompleted: Int
    let streak: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Challenge Progress")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(totalCompleted)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Total Completed")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(streak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Current Streak")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            if !mood.challenges.isEmpty {
                HStack {
                    ForEach(0..<mood.challenges.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentIndex ? mood.color : .white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                    Spacer()
                    Text("\(currentIndex + 1) of \(mood.challenges.count)")
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
    }
}