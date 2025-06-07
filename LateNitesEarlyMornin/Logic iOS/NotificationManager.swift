import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private override init() {
        super.init()
        // Set delegate to handle foreground notifications
        UNUserNotificationCenter.current().delegate = self
    }

    private let quotes = [
        "Start where you are. Use what you have. Do what you can.",
        "It's okay to rest. That is productive too.",
        "Big emotions mean you're human.",
        "Don't chase the vibe. Create it.",
        "Today is a good day to feel something new.",
        "Peace is not a place. It's a decision.",
        "Small steps each day add up to big change.",
        "You’ve survived 100% of your worst days.",
        "Growth begins outside your comfort zone.",
        "Feelings are visitors—let them come and go.",
        "Your pace is perfect exactly as it is.",
        "Choose progress over perfection today.",
        "Every emotion has something to teach you.",
        "Healing isn’t linear—be gentle with yourself.",
        "Courage is feeling the fear and doing it anyway.",
        "The only bad workout is the one you didn’t do.",
        "Gratitude turns what we have into enough.",
        "Your story isn’t over yet—keep writing.",
        "You are stronger than your struggles.",
        "Every sunrise is a new opportunity.",
        "Small acts of self-care can transform your day.",
        "Your feelings are valid and worthy of attention.",
        "Progress, not perfection, is the goal.",
        "Let go of what you can’t control and breathe.",
        "Joy often hides in the simplest moments.",
        "It’s okay to ask for help when you need it.",
        "Today’s challenges build tomorrow’s strength.",
        "Be the calm in your own storm."
    ]

    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    // MARK: - Permission Request
    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
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
        content.sound = .default
        content.userInfo = ["mood": mood.rawValue]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "mood-change-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Challenge Reminder Notification
    func scheduleChallengeReminder(for mood: Mood, delay: TimeInterval = 300) {
        let content = UNMutableNotificationContent()
        content.title = "Mood Challenge"
        content.body = ChallengeManager.challenge(for: mood)
        content.sound = .default
        content.userInfo = ["mood": mood.rawValue, "type": "challenge"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let identifier = "challenge-\(mood.rawValue)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Daily Quote Notification
    func scheduleDailyQuote(atHour hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Inspiration"
        content.body = quotes.randomElement() ?? "Hope you have a great day!"
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let identifier = "daily-quote"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Daily Mood Log Reminder
    func scheduleDailyMoodLogReminder(atHour hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Log Your Mood"
        content.body = "Don't forget to record how you're feeling today."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let identifier = "daily-mood-log"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
