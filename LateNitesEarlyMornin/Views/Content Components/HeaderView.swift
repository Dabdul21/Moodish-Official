//
//  HeaderView.swift
//  LateNitesEarlyMornin
//
//  Created by Otis Young on 6/13/25.
//


//
//  HeaderView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/6/25.
//


import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Moodish")
                    .font(.title3).bold()
                Text("Enjoy your daily quote")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    HeaderView()
}