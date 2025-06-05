//
//  StatRow.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/4/25.
//


//
//  StatRow.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 6/4/25.
//

import SwiftUI

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}