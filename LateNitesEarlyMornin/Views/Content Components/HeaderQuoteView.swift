//
//  HeaderQuoteView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/6/25.
//


import SwiftUI

struct HeaderQuoteView: View {
    var body: some View {
        VStack(spacing: 50) {
            HeaderView()
            QuoteOfTheDayView()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
