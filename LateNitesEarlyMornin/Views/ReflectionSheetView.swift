//
//  ReflectionSheetView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/6/25.
//


import SwiftUI

struct ReflectionSheetView: View {
    @Binding var isPresented: Bool
    @ObservedObject var manager: MoodHistoryManager
    let day: String
    let mood: Mood

    @State private var note: String = ""
    @State private var answer: String = ""
    @State private var rating: Int = 3

    private func emojiForRating(_ rating: Int) -> String {
        switch rating {
        case 1: return "😩"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return "❓"
        }
    }

    private func moodSpecificQuestion(for mood: Mood) -> String {
        switch mood {
        case .happy:       return "What made you smile the most today?"
        case .sad:         return "Was there something specific that brought this on?"
        case .angry:       return "What frustrated you the most today?"
        case .excited:     return "What are you looking forward to?"
        case .calm:        return "What helped you feel calm today?"
        case .nervous:     return "What made you feel uncertain today?"
        case .tired:       return "Did something wear you out today?"
        case .overwhelmed: return "What’s been the hardest to manage today?"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Reflect on Today")
                        .font(.headline)
                        .padding(.top)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why did you choose \(mood.label)?")
                            .font(.subheadline)
                        TextEditor(text: $note)
                            .frame(height: 100)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(moodSpecificQuestion(for: mood))
                            .font(.subheadline)
                        TextEditor(text: $answer)
                            .frame(height: 100)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rate your day (1–5)")
                            .font(.subheadline)
                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { num in
                                Text(emojiForRating(num))
                                    .font(.largeTitle)
                                    .opacity(rating == num ? 1 : 0.5)
                                    .onTapGesture { rating = num }
                            }
                        }
                    }

                    Button(action: {
                        manager.addEntry(day: day, mood: mood, note: note, answer: answer, rating: rating)
                        isPresented = false
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.vertical)
                }
                .padding()
            }
            .navigationTitle("Reflect")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ReflectionSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ReflectionSheetView(isPresented: .constant(true), manager: MoodHistoryManager(), day: "Monday", mood: .happy)
    }
}
