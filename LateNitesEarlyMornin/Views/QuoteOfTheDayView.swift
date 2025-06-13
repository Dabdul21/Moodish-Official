//
//  QuoteOfTheDayView.swift
//  LateNitesEarlyMornin
//
//  Created by Otis Young on 6/13/25.
//


//
//  QuoteOfTheDay.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/6/25.
//


import SwiftUI

struct QuoteOfTheDayView: View {
    private let quotes = [
        "Start where you are. Use what you have. Do what you can.",
        "It's okay to rest. That is productive too.",
        "Big emotions mean you're human.",
        "Don't chase the vibe. Create it.",
        "Today is a good day to feel something new.",
        "Peace is not a place. It's a decision.",
        "Small steps each day add up to big change.",
        "You’ve survived 100% of your worst days.",
        "Growth begins outside your comfort zone.",
        "Feelings are visitors—let them come and go.",
        "Your pace is perfect exactly as it is.",
        "Choose progress over perfection today.",
        "Every emotion has something to teach you.",
        "You are allowed to take up space.",
        "Healing isn’t linear—be gentle with yourself.",
        "Courage is feeling the fear and doing it anyway.",
        "The only bad workout is the one you didn’t do.",
        "Gratitude turns what we have into enough.",
        "Your story isn’t over yet—keep writing.",
        "You are stronger than your struggles.",
        "Every sunrise is a new opportunity.",
        "Small acts of self-care can transform your day.",
        "Your feelings are valid and worthy of attention.",
        "Progress, not perfection, is the goal.",
        "Let go of what you can’t control and breathe.",
        "Joy often hides in the simplest moments.",
        "It’s okay to ask for help when you need it.",
        "Today’s challenges build tomorrow’s strength.",
        "Be the calm in your own storm."

    ]


    @State private var currentIndex = 0
    @State private var fadeIn = false

    var body: some View {
        VStack(spacing: 16) {
            Text("“\(quotes[currentIndex])”")
                .font(.system(size: 20, weight: .medium, design: .rounded))


                .multilineTextAlignment(.center)
                .opacity(fadeIn ? 1 : 0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5)) {
                        fadeIn = true
                    }
                }

            Button("Refresh Quote") {
                withAnimation(.easeInOut(duration: 1.5)) {
                    fadeIn = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    currentIndex = (currentIndex + 1) % quotes.count
                    withAnimation(.easeInOut(duration: 1.5)) {
                        fadeIn = true
                    }
                }
            }
            .font(.caption)
        }
        .padding(.horizontal)
    }
}

#Preview {
    QuoteOfTheDayView()
}