//
//  ChallengeManager.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/2/25.
//


import Foundation

struct ChallengeManager {
    static func challenge(for mood: Mood) -> String {
        switch mood {
        case .happy:
            return "Send a positive text message to a loved one."
        case .calm:
            return "Send someone a 'thank you' or 'thinking of you' text."
        case .nervous:
            return "Take 3 deep breaths: in for 3, out for 6."
        case .sad:
            return "Write a short note to yourself like you would to a friend who's sad."
        case .overwhelmed:
            return "Write a short note to yourself like you would to a friend who's sad."
        case .tired:
            return "Turn your phone screen brightness all the way down and reduce volume."
        case .excited:
            return "Record a 30-second voice memo describing why you're excited."
        case .angry:
            return "Draw an imaginary line in the air and erase it."
        }
    }
}
