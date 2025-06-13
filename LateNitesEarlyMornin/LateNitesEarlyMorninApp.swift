//
//  LateNitesEarlyMorninApp.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/27/25.
//

import SwiftUI

@main
struct LateNitesEarlyMorninApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .onAppear {
                    // Request notification permission when app launches
                    NotificationManager.shared.requestNotificationPermission()

                    notificationManager.scheduleDailyQuote(atHour: 9, minute: 0)
                    notificationManager.scheduleDailyMoodLogReminder(atHour: 20, minute: 0)
                }
        }
    }
}
