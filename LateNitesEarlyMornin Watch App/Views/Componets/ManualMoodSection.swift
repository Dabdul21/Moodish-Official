//
//  ManualMoodSection.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/4/25.
//


//
//  ManualMoodSection.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 6/4/25.
//

import SwiftUI

struct ManualMoodSection: View {
    let isActive: Bool
    let remainingMinutes: Int
    let onReset: () -> Void
    let onChange: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            if isActive {
                HStack {
                    Text("Manual Override Active")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Text("\(remainingMinutes) min left")
                        .font(.caption2)
                        .foregroundColor(.orange.opacity(0.8))
                }
                
                HStack(spacing: 8) {
                    Button("Reset to Auto") {
                        onReset()
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
                        onChange()
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
                Button(action: onChange) {
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
    }
}