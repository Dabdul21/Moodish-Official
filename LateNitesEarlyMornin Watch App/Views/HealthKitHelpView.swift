//
//  HealthKitHelpView.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 5/28/25.
//

//MARK: User will only come here if they dont allow HealthKit, it willl show them how to change settings to allow than 
import SwiftUI

struct HealthKitHelpView: View {
    var retryAction: () -> Void
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                Text("Health Access Needed")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Text("""
                    To continue, open the Watch app on your iPhone:
                    
                    1. Tap 'Privacy' > 'Health'
                    
                    2. Enable access for Moodish
                    
                    Return here and tap 'Try Again' 
                    """)
                .font(.caption)
                .multilineTextAlignment(.center)
                
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
                
                Button("Try Again") {
                    retryAction()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            .padding()
        }
    }
}

#Preview{
    HealthKitHelpView(retryAction:{
        print("it wont print this ")})
}
