//
//  LateNitesEarlyMorninApp.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 5/27/25.
//


//MARK: App runs from here because if the user is opening it for the first time it needs to figure out what screen to send them to hence why we r using this instead of good ol content view 'MoodStatusView' is the default screen you will be in once youve used the app. The picker will than become a button just in case you wanted to change your mood if the app predicted it incorrectly

import SwiftUI

@main
struct LateNitesEarlyMornin_Watch_AppApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var healthManager = HealthManager()

    var body: some Scene {
        WindowGroup {
            if hasLaunchedBefore {
                MoodStatusView()
                    .environmentObject(healthManager)
                    .environmentObject(notificationManager)
                    .onAppear {
                        // refresh all data and notifications on every launch
                        healthManager.fetchAllHealthData()
                        notificationManager.requestNotificationPermission()
                        notificationManager.scheduleDailyQuote(atHour: 9, minute: 0)
                    }
            } else {
                LaunchLoadingView()
                    .environmentObject(healthManager)
                    .environmentObject(notificationManager)
                    // whenever HealthKit finally authorizes, mark first launch done
                    .onChange(of: healthManager.healthKitAuthorized) { authorized in
                        if authorized {
                            hasLaunchedBefore = true
                        }
                    }
                    .onAppear {
                        // fire notification permission & daily quote once
                        notificationManager.requestNotificationPermission()
                        notificationManager.scheduleDailyQuote(atHour: 9, minute: 0)
                    }
            }
        }
    }
}
