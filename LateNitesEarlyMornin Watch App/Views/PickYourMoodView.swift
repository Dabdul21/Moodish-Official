//
//  PickYourMoodView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/28/25.
//

import SwiftUI

struct PickYourMoodView: View {
    @State private var selectedMood: Mood = .happy
    @FocusState private var pickerFocused: Bool
    @State private var showMoodStatus = false
    @EnvironmentObject var notificationManager: NotificationManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 5) {
                HStack {
//                    Spacer()
                    AnimatedWelcomeText() //is in animation folder
                }

                Text("How do you feel?")
                    .font(.headline)
//                    .padding(.top, 2)

                Picker("",selection: $selectedMood) { //left the argument empty but Pick a mood: was there
                    
                    ForEach(Mood.allCases) { mood in
                        Text(mood.label).tag(mood)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 73)
                .focusable(true)
                .focused($pickerFocused)
                .padding(.top, 2)

                Button(action: {
                    // Send mood change notification
                    notificationManager.notifyMoodChange(to: selectedMood)
                    
                    // Schedule challenge reminder (5 minutes later)
                    notificationManager.scheduleChallengeReminder(for: selectedMood)
                    
                    showMoodStatus = true
                }) {
                    Text("Continue")
                        .font(.caption2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 8).fill(selectedMood.color.opacity(0.3)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedMood.color, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 5)

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $showMoodStatus) {
                MoodStatusView()
            }
            .onAppear {
                pickerFocused = true
            }
        }
    }
}


#Preview{
    PickYourMoodView()
        .environmentObject(NotificationManager.shared)
}
