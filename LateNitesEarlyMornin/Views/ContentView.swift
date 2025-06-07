//
//  ContentView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/6/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var historyManager = MoodHistoryManager()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HeaderQuoteView()
                Divider().padding(.horizontal)

                WeeklyVibeEditorView(manager: historyManager)

                Divider().padding(.horizontal)

                MoodHistoryView(manager: historyManager)
            }
            .frame(maxWidth: 700)
            .padding(.vertical, 40)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

#Preview {
    ContentView()
}
