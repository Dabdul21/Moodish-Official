//
//  ContentView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/27/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("LateNite IOS")
                .font(.headline)
                .foregroundColor(.blue)
            
            Image(systemName: "heart.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.red)
            
            Text("IOS App Working!")
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
