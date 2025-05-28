//
//  LateNitesEarlyMorninApp.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 5/27/25.
//

import SwiftUI

//MARK: App runs from here beause if the user is opening it for the first time it needs to figure out what screen to send them too hence why we r using this instead of good ol content view 'MoodStatusView' is the defult screen you will be in once youve used the app. The picker will than become a button just in case you wanted to change your mood if the app predicted it incorrectly

@main
struct LateNitesEarlyMornin_Watch_AppApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    var body: some Scene {
        WindowGroup {
            if hasLaunchedBefore {
                MoodStatusView()
            } else {
                LaunchLoadingView()
                    .onDisappear {
                        hasLaunchedBefore = true
                    }
            }
        }
    }
}
