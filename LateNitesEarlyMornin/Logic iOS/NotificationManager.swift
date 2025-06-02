//
//  NotificationManager.swift
//  LateNitesEarlyMornin
//
//  Created by Dayan Abdulla on 6/2/25.
//


import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Permission Request
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
                
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Mood Change Notification
    func notifyMoodChange(to mood: Mood) {
        let content = UNMutableNotificationContent()
        content.title = "Mood Updated"
        content.body = "Your mood has been set to \(mood.label)"
        content.sound = UNNotificationSound.default
        
        // Add custom data
        content.userInfo = ["mood": mood.rawValue]
        
        // Create trigger (immediate delivery)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "mood-change-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling mood notification: \(error.localizedDescription)")
            } else {
                print("Mood change notification scheduled for: \(mood.label)")
            }
        }
    }
    
    // MARK: - Challenge Reminder Notification
    func scheduleChallengeReminder(for mood: Mood, delay: TimeInterval = 300) { // 5 minutes default
        let content = UNMutableNotificationContent()
        content.title = "Mood Challenge"
        content.body = ChallengeManager.challenge(for: mood)
        content.sound = UNNotificationSound.default
        
        // Add custom data
        content.userInfo = ["mood": mood.rawValue, "type": "challenge"]
        
        // Create trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "challenge-\(mood.rawValue)",
            content: content,
            trigger: trigger
        )
        
        // Remove any existing challenge notifications first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["challenge-\(mood.rawValue)"])
        
        // Schedule new notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling challenge notification: \(error.localizedDescription)")
            } else {
                print("Challenge reminder scheduled for: \(mood.label)")
            }
        }
    }
}