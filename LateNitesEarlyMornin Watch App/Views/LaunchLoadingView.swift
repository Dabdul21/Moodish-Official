//
//  LaunchLoadingView.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 5/28/25.
//

import SwiftUI

struct LaunchLoadingView: View {
    @StateObject private var healthManager = HealthManager()
    @EnvironmentObject var notificationManager: NotificationManager
    
    var body: some View {
        Group {
            if healthManager.shouldShowHealthKitHelp {
                HealthKitHelpView {
                    healthManager.requestAuthorization()
                }
            } else if healthManager.healthKitAuthorized {
                // Go directly to MoodStatusView since it shows inferred mood
                NavigationStack {
                    MoodStatusView()
                        .environmentObject(healthManager)
                        .environmentObject(notificationManager)
                }
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
                    
                    // Request notification permission during initial setup
                    notificationManager.requestNotificationPermission()
                }
            }
        }
    }
}

#Preview {
    LaunchLoadingView()
        .environmentObject(NotificationManager.shared)
}
