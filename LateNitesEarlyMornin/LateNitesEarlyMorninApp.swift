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
                    notificationManager.requestNotificationPermission()
                }
        }
    }
}
