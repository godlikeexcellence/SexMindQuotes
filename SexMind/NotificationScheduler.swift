import Foundation
import UserNotifications

struct NotificationScheduler {
    static func scheduleDailyNotification(at time: Date) {
        let center = UNUserNotificationCenter.current()

        // Prepare notification content
        let content = UNMutableNotificationContent()
        content.title = "💬 SexMind"
        content.body = SexMindQuotes.random()
        content.sound = UNNotificationSound(named: UNNotificationSoundName("Positive_Reminder_FadeIn_Fixed.wav"))

        // Extract hour and minute from selected time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        // Schedule daily trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        // Use same ID to replace existing custom daily notification
        let request = UNNotificationRequest(identifier: "SexMindDailyCustom", content: content, trigger: trigger)

        // Add the request
        center.add(request) { error in
            if let error = error {
                print("❌ Failed to schedule custom notification: \(error.localizedDescription)")
            } else {
                print("✅ Custom daily notification scheduled at \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
}

