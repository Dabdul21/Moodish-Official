//
//  LateNitesEarlyMorninApp.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 5/27/25.
//

import SwiftUI

@main
struct LateNitesEarlyMornin_Watch_AppApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    var body: some Scene {
        WindowGroup {
            if hasLaunchedBefore {
                MoodStatusView()
            } else {
                PickYourMoodView()
                    .onDisappear {
                        hasLaunchedBefore = true
                    }
            }
        }
    }
}
