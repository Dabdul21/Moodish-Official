//
//  MoodExtensions.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 6/4/25.
//

import SwiftUI

// MARK: - Mood Extensions
extension Mood {
    var tip: String {
        switch self {
        case .overwhelmed:
            return "Take it one step at a time."
        case .happy:
            return "Keep that energy flowing!"
        case .excited:
            return "Channel that excitement into action!"
        case .calm:
            return "Enjoy this peaceful moment."
        case .angry:
            return "Let it flow, then let it go."
        case .nervous:
            return "You've got this. Breathe."
        case .sad:
            return "It's okay to rest. Breathe."
        case .tired:
            return "Rest is productive too."
        }
    }
}

// MARK: - Date Extensions
extension Date {
    func timeAgoShort() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}