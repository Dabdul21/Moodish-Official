//
//  ContentView.swift
//  LateNitesEarlyMornin Watch App
//
//  Created by Dayan Abdulla on 5/27/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("LateNite WatchOS")
                .font(.headline)
                .foregroundColor(.blue)
            
            Image(systemName: "heart.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.red)
            
            Text("Watch App Working!")
                .font(.caption)
                .foregroundColor(.green)
            
        }
        
        .padding()
    }
}

#Preview {
    ContentView()
}
