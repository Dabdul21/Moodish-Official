//
//  LateNitesEarlyMorninApp.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 5/27/25.
//

import SwiftUI

//MARK: App runs from here because if the user is opening it for the first time it needs to figure out what screen to send them to hence why we r using this instead of good ol content view 'MoodStatusView' is the default screen you will be in once youve used the app. The picker will than become a button just in case you wanted to change your mood if the app predicted it incorrectly

@main
struct LateNitesEarlyMornin_Watch_AppApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            if hasLaunchedBefore {
                MoodStatusView()
                    .environmentObject(notificationManager)
                    .onAppear {
                        // Request notification permission when returning user opens app
                        notificationManager.requestNotificationPermission()
                    }
            } else {
                LaunchLoadingView()
                    .environmentObject(notificationManager)
                    .onDisappear {
                        hasLaunchedBefore = true
                    }
                    .onAppear {
                        // Request notification permission when first-time user opens app
                        notificationManager.requestNotificationPermission()
                    }
            }
        }
    }
}
