//
//  FullHistoryView.swift
//  LateNitesEarlyMornin
//
//  Created by Otis Young on 6/13/25.
//


//
//  FullHistoryView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/6/25.
//


import SwiftUI

struct FullHistoryView: View {
    @ObservedObject var manager: MoodHistoryManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    ForEach(Array(manager.entries.enumerated()), id: \.element.id) { index, entry in
                        NavigationLink(destination: MoodEntryDetailView(entry: entry)) {
                            HistoryRow(entry: entry)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Insert spacer after each full week
                        if (index + 1) % 7 == 0 {
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("All Mood History")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct HistoryRow: View {
    let entry: MoodLogEntry
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.day)
                    .font(.headline)
                Text(dateFormatter.string(from: entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(entry.mood.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .shadow(color: entry.mood.color.opacity(0.3), radius: 10, x: 0, y: 5)
                Image(systemName: iconForMood(entry.mood))
                    .font(.system(size: 36))
                    .foregroundColor(entry.mood.color)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct MoodEntryDetailView: View {
    let entry: MoodLogEntry
    @Environment(\.presentationMode) var presentationMode

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df
    }()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.day)
                        .font(.largeTitle)
                        .bold()
                    Text(dateFormatter.string(from: entry.date))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)

                HStack(spacing: 16) {
                    Circle()
                        .fill(entry.mood.color)
                        .frame(width: 80, height: 80)
                        .shadow(color: entry.mood.color.opacity(0.3), radius: 10, x: 0, y: 5)
                        .overlay(
                            Image(systemName: iconForMood(entry.mood))
                                .font(.title2)
                                .foregroundColor(.white)
                        )
                    Text(entry.mood.label)
                        .font(.title2)
                        .bold()
                }

                HStack(alignment: .center, spacing: 12) {
                    Text("Rating:")
                        .font(.headline)
                    Text(emojiForRating(entry.rating))
                        .font(.system(size: 48))
                }

                if !entry.note.isEmpty {
                    SectionCard(title: "Why I chose this mood", content: entry.note)
                }

                if !entry.answer.isEmpty {
                    SectionCard(title: "Follow-up response", content: entry.answer)
                }

                Spacer(minLength: 20)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Details")
        .navigationBarItems(trailing: Button("Done") {
            presentationMode.wrappedValue.dismiss()
        })
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionCard: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
        }
        .padding(.horizontal)
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

// Preview
#Preview {
    FullHistoryView(manager: MoodHistoryManager())
}