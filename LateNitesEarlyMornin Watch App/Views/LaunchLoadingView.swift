//
//  LaunchLoadingView.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 5/28/25.
//

import SwiftUI

struct LaunchLoadingView: View {
    @StateObject private var healthManager = HealthManager()
    
    var body: some View {
        Group {
            if healthManager.shouldShowHealthKitHelp {
                HealthKitHelpView {
                    healthManager.requestAuthorization()
                }
            } else if healthManager.healthKitAuthorized {
                PickYourMoodView()
                    .environmentObject(healthManager)
            } else {
                VStack {
                    Image("Moodish")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 100)

                    ProgressView("Loading…")
                        .padding(.top, 8)
                }
                .onAppear {
                    healthManager.requestAuthorization()
                }
            }
        }
    }
}

#Preview {
    LaunchLoadingView()
}
