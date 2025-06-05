////
////  MoodHistoryManager.swift
////  LateNitesEarlyMornin Watch App
////
////  Created by Dayan Abdulla on 6/4/25.
////
//
//import SwiftUI
//
//// MARK: - Mood Log Entry
//struct MoodLogEntry: Codable, Identifiable {
//    let id = UUID()
//    let mood: Mood
//    let timestamp: Date
//    let note: String?
//    let wasInferred: Bool
//}
//
//// MARK: - Mood History Manager
//class MoodHistoryManager: ObservableObject {
//    @Published var moodHistory: [MoodLogEntry] = []
//    @AppStorage("moodHistoryData") private var moodHistoryData: Data = Data()
//    
//    init() {
//        loadHistory()
//    }
//    
//    func logMood(_ mood: Mood, note: String? = nil, wasInferred: Bool = true) {
//        let entry = MoodLogEntry(
//            mood: mood,
//            timestamp: Date(),
//            note: note,
//            wasInferred: wasInferred
//        )
//        
//        moodHistory.insert(entry, at: 0) // Most recent first
//        
//        // Keep only last 50 entries to save storage
//        if moodHistory.count > 50 {
//            moodHistory = Array(moodHistory.prefix(50))
//        }
//        
//        saveHistory()
//    }
//    
//    var recentMoods: [Mood] {
//        return Array(moodHistory.prefix(5).map { $0.mood })
//    }
//    
//    private func saveHistory() {
//        if let encoded = try? JSONEncoder().encode(moodHistory) {
//            moodHistoryData = encoded
//        }
//    }
//    
//    private func loadHistory() {
//        if let decoded = try? JSONDecoder().decode([MoodLogEntry].self, from: moodHistoryData) {
//            moodHistory = decoded
//        }
//    }
//}
