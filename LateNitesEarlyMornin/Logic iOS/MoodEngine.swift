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
        
        print("DEBUG MoodEngine - HR: \(heartRate), Steps: \(steps), Exercise: \(exerciseMinutes), Sleep: \(sleepStage)")
        
        // If we have no meaningful health data at all, default to happy (not calm)
        if heartRate <= 0 && steps <= 0 && exerciseMinutes <= 0 {
            print("DEBUG: No meaningful data available, returning happy")
            return .happy
        }
        
        // Priority 1: Sleep-based moods (if we have recent sleep data)
        if sleepStage != "Unknown" && sleepStage != "Awake" {
            if sleepStage == "Deep" || sleepStage == "Core" {
                if heartRate > 0 && heartRate < 65 {
                    print("DEBUG: Deep/Core sleep + low HR = tired")
                    return .tired
                }
            }
            if sleepStage == "REM" {
                if heartRate > 0 && heartRate < 70 {
                    print("DEBUG: REM sleep + low HR = sad or tired")
                    return steps < 100 ? .sad : .tired
                }
            }
        }
        
        // Priority 2: High activity scenarios
        if steps > 0 && exerciseMinutes > 0 {
            // Very active day
            if steps > 8000 || exerciseMinutes > 30 {
                if heartRate > 90 {
                    print("DEBUG: High activity + high HR = excited")
                    return .excited
                } else {
                    print("DEBUG: High activity + normal HR = happy")
                    return .happy
                }
            }
            
            // Good moderate activity
            if steps > 3000 && exerciseMinutes > 15 {
                if heartRate > 0 && heartRate < 80 {
                    print("DEBUG: Good activity + moderate HR = calm")
                    return .calm
                } else {
                    print("DEBUG: Good activity = happy")
                    return .happy
                }
            }
        }
        
        // Priority 3: Heart rate patterns (if we have heart rate data)
        if heartRate > 0 {
            // High heart rate scenarios
            if heartRate > 100 {
                if steps < 500 {
                    // High HR but low movement - could be stress/anxiety
                    print("DEBUG: Very high HR + low activity = nervous")
                    return .nervous
                } else {
                    // High HR with movement - probably excited/active
                    print("DEBUG: Very high HR + activity = excited")
                    return .excited
                }
            }
            
            // Elevated heart rate
            if heartRate > 85 {
                if steps < 1000 && exerciseMinutes < 5 {
                    // Elevated HR but not much activity - could be stressed
                    print("DEBUG: High HR + low activity = angry or nervous")
                    return sleepStage == "Awake" ? .nervous : .angry
                }
            }
            
            // Very low heart rate
            if heartRate < 55 {
                print("DEBUG: Very low HR = tired")
                return .tired
            }
        }
        
        // Priority 4: Activity-based inferences (when heart rate isn't available)
        if steps > 0 || exerciseMinutes > 0 {
            // Very low activity
            if steps < 500 && exerciseMinutes < 5 {
                print("DEBUG: Very low activity = overwhelmed")
                return .overwhelmed
            }
            
            // Low activity
            if steps < 1500 && exerciseMinutes < 10 {
                print("DEBUG: Low activity = sad or tired")
                return heartRate > 0 && heartRate < 70 ? .sad : .tired
            }
        }
        
        // Priority 5: Time-based defaults (if we have no good data)
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 7 || hour > 22 {
            print("DEBUG: Late/early hours = tired")
            return .tired
        }
        
        if hour >= 7 && hour < 12 {
            print("DEBUG: Morning hours = happy")
            return .happy
        }
        
        // Final fallback - default to happy (most positive assumption)
        print("DEBUG: Final fallback = happy")
        return .happy
    }
}
