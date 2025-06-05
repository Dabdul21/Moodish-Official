//
//  AnimatedWelcomeText.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/28/25.
//

import SwiftUI

struct AnimatedWelcomeText: View {
    @State private var offsetX: CGFloat = 0
    let text = "Manual Mood Override!"

    var body: some View {
        GeometryReader { geo in
            let viewWidth = geo.size.width // how far to move across
            let travelDistance = viewWidth // same thing just cleaner

            Text(text)
                .font(.caption)
                .foregroundColor(.red)
                .offset(x: offsetX) // moves it left/right
                .frame(width: viewWidth, alignment: .center) // center it in frame
                .onAppear {
                    if travelDistance > 0 {
                        runAnimationCycle(distance: travelDistance, repeatCount: 1)
                    } else {
                        // Retry after a slight delay if width is still 0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            runAnimationCycle(distance: geo.size.width, repeatCount: 2)
                        }
                    }
                }

        }
        .frame(height: 20) // keep it tight height wise
    }

    private func runAnimationCycle(distance: CGFloat, repeatCount: Int) {
        guard repeatCount > 0 else { return } // dont do nuthin if 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { // wait b4 we start
            withAnimation(.linear(duration: 2)) {
                offsetX = -distance // slide left
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // wait till off screen
                offsetX = distance // jump to right

                withAnimation(.linear(duration: 1.1)) {
                    offsetX = 0 // glide back to middle
                }

                // do again if repeat is > 1
                if repeatCount > 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        runAnimationCycle(distance: distance, repeatCount: repeatCount - 1)
                    }
                }
            }
        }
    }
}

#Preview {
    AnimatedWelcomeText()
}
