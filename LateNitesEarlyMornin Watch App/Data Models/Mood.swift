//
//  Mood.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/28/25.
//

import SwiftUI

enum Mood: String, CaseIterable, Identifiable, Codable {
    case overwhelmed
    case happy
    case excited
    case calm
    case angry
    case nervous
    case sad
    case tired

    var id: String { rawValue }

    var label: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {                                                               //Hex codee
        case .overwhelmed: return Color(red: 143/255, green: 93/255, blue: 70/255)     // 8F5D46
        case .happy:       return Color(red: 249/255, green: 165/255, blue: 199/255)   // F9A5C7
        case .excited:     return Color(red: 98/255, green: 45/255, blue: 145/255)     // 622D91
        case .calm:        return Color(red: 0/255, green: 0/255, blue: 255/255)       // 0000FF
        case .angry:       return Color(red: 255/255, green: 54/255, blue: 54/255)     // FF3636
        case .nervous:     return Color(red: 252/255, green: 238/255, blue: 33/255)    // FCEE21
        case .sad:         return Color(red: 128/255, green: 128/255, blue: 128/255)   // 808080
        case .tired:       return Color(red: 3/255, green: 229/255, blue: 137/255)     // 03E589
        }
    }

    var imageName: String {
        label // images is gonn be named like "Happy" or "Sad" first letter capital casee
    }
}
