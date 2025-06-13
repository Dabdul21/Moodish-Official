//
//  WeeklyVibeEditorView.swift
//  LateNitesEarlyMornin
//
//  Created by Otis Young on 6/13/25.
//


//
//  WeeklyVibeScrollView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/6/25.
//


import SwiftUI

struct WeeklyVibeEditorView: View {
    @ObservedObject var manager: MoodHistoryManager
    @State private var selectedDay: String = Calendar.current.weekdaySymbols[(Calendar.current.component(.weekday, from: Date()) - 1)]
    @State private var selectedMood: Mood = .happy
    @State private var showReflectionSheet = false

    private let days = Calendar.current.weekdaySymbols

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Select Day:")
                    .font(.headline)
                Spacer()
                Picker("Day", selection: $selectedDay) {
                    ForEach(days, id: \.self) { day in
                        Text(day)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal)

            Text("What's the vibe for \(selectedDay)?")
                .font(.title3)
                .bold()

            let columns = [GridItem(.adaptive(minimum: 80), spacing: 16)]
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Mood.allCases) { mood in
                    VStack(spacing: 8) {
                        Circle()
                            .fill(mood.color)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: iconForMood(mood))
                                    .font(.title2)
                                    .foregroundColor(.white)
                            )
                        Text(mood.label)
                            .font(.caption)
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedMood == mood ? Color.accentColor : .clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedMood = mood
                        showReflectionSheet = true
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
        .fullScreenCover(isPresented: $showReflectionSheet) {
            ReflectionSheetView(
                isPresented: $showReflectionSheet,
                manager: manager,
                day: selectedDay,
                mood: selectedMood
            )
        }

    }

    private func iconForMood(_ mood: Mood) -> String {
        switch mood {
        case .happy:       return "sun.max.fill"
        case .sad:         return "cloud.rain.fill"
        case .angry:       return "flame.fill"
        case .excited:     return "sparkles"
        case .nervous:     return "bolt.fill"
        case .calm:        return "wind"
        case .tired:       return "moon.zzz.fill"
        case .overwhelmed: return "exclamationmark.triangle.fill"
        }
    }
}

struct WeeklyVibeEditorView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyVibeEditorView(manager: MoodHistoryManager())
    }
}