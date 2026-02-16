import Foundation
import UserNotifications
import UIKit
import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            Task { @MainActor in
                self.isAuthorized = granted
            }
            
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        self.isAuthorized = settings.authorizationStatus == .authorized
    }
    
    func scheduleWasherNotification(in seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Washing Complete! 🧺"
        content.body = "Your laundry is ready. Time to take it out!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "washer_timer", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling washer notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleDryerNotification(in seconds: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Drying Complete! ☀️"
        content.body = "Your clothes are dry. Time to fold them!"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "dryer_timer", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling dryer notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelWasherNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["washer_timer"])
    }
    
    func cancelDryerNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dryer_timer"])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    nonisolated func clearBadge() {
        Task { @MainActor in
            UNUserNotificationCenter.current().setBadgeCount(0)
        }
    }
    
    nonisolated func vibrateSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    nonisolated func vibrateWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    nonisolated func vibrateError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    nonisolated func vibrateLight() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    nonisolated func vibrateMedium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    nonisolated func vibrateHeavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    nonisolated func vibrateSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
