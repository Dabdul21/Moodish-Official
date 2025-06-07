//
//  MoodLogEntry.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/6/25.
//


import SwiftUI

struct MoodLogEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let day: String
    let mood: Mood
    let note: String
    let answer: String
    let rating: Int
}

class MoodHistoryManager: ObservableObject {
    @Published var entries: [MoodLogEntry] = []
    @AppStorage("moodHistoryData") private var storedData: Data = Data()

    init() {
        load()
    }

    func addEntry(day: String, mood: Mood, note: String, answer: String, rating: Int) {
        let entry = MoodLogEntry(
            id: UUID(),
            date: Date(),
            day: day,
            mood: mood,
            note: note,
            answer: answer,
            rating: rating
        )
        entries.insert(entry, at: 0)
        if entries.count > 7 {
            entries = Array(entries.prefix(7))
        }
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(entries) {
            storedData = encoded
        }
    }

    private func load() {
        if let decoded = try? JSONDecoder().decode([MoodLogEntry].self, from: storedData) {
            entries = decoded
        }
    }
}

struct MoodHistoryView: View {
    @ObservedObject var manager: MoodHistoryManager
    @State private var showFullHistory = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mood History")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            if manager.entries.isEmpty {
                Text("No mood entries yet.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(manager.entries.prefix(3)) { entry in
                            HistoryCard(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                }

                // See All button
                if manager.entries.count > 3 {
                    Button("See All History") {
                        showFullHistory = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
        }
        .fullScreenCover(isPresented: $showFullHistory) {
            FullHistoryView(manager: manager)
        }
    }
}

struct HistoryCard: View {
    let entry: MoodLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.day)
                    .font(.headline)
                Spacer()
                Text(emojiForRating(entry.rating))
            }

            HStack(spacing: 8) {
//                Circle()
//                    .fill(entry.mood.color)
//                    .frame(width: 24, height: 24)
                
                Circle()
                    .fill(entry.mood.color.opacity(0.2))
                    .frame(width: 30, height: 30)
                    .shadow(color: entry.mood.color.opacity(0.3), radius: 10, x: 0, y: 5)
                    .overlay {
                        Image(systemName: iconForMood(entry.mood))
                            .font(.system(size: 15))
                            .foregroundColor(entry.mood.color)
                    }
                
                
                Text(entry.mood.label)
                    .font(.subheadline)
            }

            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.body)
                    .italic()
                    .padding(.leading, 32)
            }
            if !entry.answer.isEmpty {
                Text(entry.answer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 32)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }

    private func emojiForRating(_ r: Int) -> String {
        switch r {
        case 1: return "😩"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "❓"
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

#Preview {
    MoodHistoryView(manager: MoodHistoryManager())
}

