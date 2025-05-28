//
//  MoodEngine.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/28/25.
//

import Foundation

struct MoodEngine {
    static func inferMood(
        heartRate: Double,
        steps: Double,
        exerciseMinutes: Double,
        sleepStage: String
    ) -> Mood {
        // no data fallback to calm
        if heartRate == 0 && steps == 0 && exerciseMinutes == 0 {
            return .calm
        }

        if sleepStage == "Deep" && heartRate < 60 {
            return .tired
        }

        if heartRate > 100 && steps > 5000 {
            return .excited
        }

        if heartRate > 100 && steps < 100 {
            return .angry
        }

        if sleepStage == "REM" && heartRate < 60 {
            return .sad
        }

        if steps < 100 && exerciseMinutes < 5 {
            return .overwhelmed
        }

        if sleepStage == "Awake" && heartRate > 90 {
            return .nervous
        }

        if heartRate < 75 && exerciseMinutes > 20 {
            return .calm
        }

        return .happy // fallback mood
    }
}
