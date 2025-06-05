//
//  PickYourMoodView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/28/25.
//

import SwiftUI

struct PickYourMoodView: View {
    @State private var selectedMood: Mood
    @FocusState private var pickerFocused: Bool
    @State private var showMoodStatus = false
    @EnvironmentObject var notificationManager: NotificationManager
    
    // Optional callback for manual mood override
    private let onMoodSelected: ((Mood) -> Void)?
    private let isManualOverride: Bool
    
    // Default initializer for original use case
    init() {
        self._selectedMood = State(initialValue: .happy)
        self.onMoodSelected = nil
        self.isManualOverride = false
    }
    
    // Initializer for manual mood override
    init(selectedMood: Mood, onMoodSelected: @escaping (Mood) -> Void) {
        self._selectedMood = State(initialValue: selectedMood)
        self.onMoodSelected = onMoodSelected
        self.isManualOverride = true
    }

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                if isManualOverride {
                    AnimatedWelcomeText() //is in animation folder
                }
            }


            if isManualOverride {
                Text("How do you feel?")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            Picker("", selection: $selectedMood) {
                ForEach(Mood.allCases) { mood in
                    Text(mood.label).tag(mood)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 73)
            .focusable(true)
            .focused($pickerFocused)
            .padding(.top, 2)

            if isManualOverride {
                // Manual override buttons
                HStack(spacing: 12) {
                    Button("Cancel") {
                        // Go back without changing mood - pass the original mood
                        onMoodSelected?(selectedMood)
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                    )
                    
                    Button("Set Mood") {
                        onMoodSelected?(selectedMood)
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedMood.color)
                    )
                }
                .buttonStyle(.plain)
            } else {
                // Original continue button
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
            }

            Spacer()
        }
        .padding()
        .background(isManualOverride ? .black : .clear)
        .navigationTitle(isManualOverride ? "" : "")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showMoodStatus) {
            MoodStatusView()
        }
        .onAppear {
            pickerFocused = true
        }
    }
}

#Preview {
    PickYourMoodView()
}
