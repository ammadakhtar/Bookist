//
//  NotificationManager.swift
//  Bookist
//
//  Created by Ammad Akhtar on 24/12/2025.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized: Bool = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isDailyReminderScheduled: Bool = false

    private let notificationCenter = UNUserNotificationCenter.current()
    private let dailyReminderIdentifier = "bookist_daily_reminder"

    // Reading reminder content
    private let readingReminders = [
        (title: "📚 Time to Read", subtitle: "A few pages today keeps boredom away"),
        (title: "📖 Your Books Are Waiting", subtitle: "Dive into your next chapter tonight"),
        (title: "✨ Reading Time", subtitle: "End your day with a good book"),
        (title: "📕 Don't Forget to Read", subtitle: "Your daily escape into stories awaits"),
        (title: "🌙 Evening Reading", subtitle: "The perfect time to lose yourself in a book"),
        (title: "📗 Keep Your Streak Going", subtitle: "Read a few pages to maintain your momentum"),
        (title: "💭 Story Time", subtitle: "Let's continue your reading journey tonight")
    ]

    override init() {
        super.init()
        notificationCenter.delegate = self
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )

            await MainActor.run {
                self.isAuthorized = granted
            }

            await checkAuthorizationStatus()

            if granted {
                print("✅ Notification permission granted - scheduling daily reminder")
                await scheduleDailyReminder()
            } else {
                print("❌ Notification permission denied")
            }

            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()

        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    private func checkAuthorizationStatus() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Daily Reminder Scheduling

    func scheduleDailyReminder() async {
        guard isAuthorized else {
            print("Notification permission not granted")
            return
        }

        // Check if already scheduled to avoid duplicates
        if isDailyReminderScheduled {
            print("⏰ Daily reminder already scheduled - skipping")
            return
        }

        // Remove existing reminder
        await removeReminder()

        // Get a random reading reminder
        let reminder = readingReminders.randomElement() ?? readingReminders[0]

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.subtitle
        content.sound = .default

        // Set the app icon badge
        content.badge = 1

        // Add custom user info to identify this notification
        content.userInfo = [
            "type": "daily_reading_reminder",
            "scheduledAt": Date().timeIntervalSince1970
        ]

        // Create date components for 10 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 22  // 10 PM in 24-hour format
        dateComponents.minute = 0

        // Create the trigger (repeats daily)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        // Create the notification request
        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
            await MainActor.run {
                self.isDailyReminderScheduled = true
            }
            print("✅ Daily reading reminder scheduled for 10 PM")
        } catch {
            print("❌ Failed to schedule daily reminder: \(error)")
        }
    }

    func removeReminder() async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
        await MainActor.run {
            self.isDailyReminderScheduled = false
        }
        print("🗑️ Removed existing daily reminder")
    }

    // MARK: - App State Management

    func handleAppDidBecomeActive() {
        print("📱 App became active - clearing badge and checking notifications")
        
        // Clear badge immediately when app becomes active
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        Task { @MainActor in
            // Also use the new API for iOS 16+
            if #available(iOS 16.0, *) {
                try? await notificationCenter.setBadgeCount(0)
            }
            
            // Check if we need to reschedule notifications (in case settings changed)
            await checkAuthorizationStatus()
            if isAuthorized {
                await scheduleDailyReminder()
            }
        }
    }

    func handleAppWillResignActive() {
        // App is going to background - notification will fire if scheduled
        print("📱 App going to background - daily reminder will fire at 10 PM if scheduled")
    }

    // MARK: - Utility Methods

    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }

    func getDeliveredNotifications() async -> [UNNotification] {
        return await notificationCenter.deliveredNotifications()
    }

    func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        Task {
            if #available(iOS 16.0, *) {
                try? await notificationCenter.setBadgeCount(0)
            }
        }
    }

    // MARK: - Debug Methods

    func debugScheduledNotifications() async {
        let pending = await getPendingNotifications()
        print("📋 Pending notifications: \(pending.count)")

        for notification in pending {
            print("  - \(notification.identifier): \(notification.content.title)")
            if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                print("    Scheduled for: \(trigger.dateComponents)")
            }
        }
    }

    // Test notification (for debugging)
    func scheduleTestNotification(delaySeconds: TimeInterval = 5) async {
        guard isAuthorized else {
            print("❌ Notification permission not granted - cannot schedule test notification")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "🧪 Test Notification"
        content.body = "This is a test reading reminder notification"
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: delaySeconds,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "test_notification",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
        print("🧪 Test notification scheduled for \(delaySeconds) seconds")
    }

    // Schedule immediate test reminder (useful for testing)
    func scheduleImmediateTestReminder() async {
        guard isAuthorized else {
            print("❌ Notification permission not granted")
            return
        }

        let reminder = readingReminders.randomElement() ?? readingReminders[0]

        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.subtitle
        content.sound = .default
        content.badge = 1
        content.userInfo = [
            "type": "test_reading_reminder",
            "scheduledAt": Date().timeIntervalSince1970
        ]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 3,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "test_reading_reminder_immediate",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
        print("📚 Test reading reminder scheduled for 3 seconds")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    // Called when notification is received while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {

        // Check if this is our daily reminder
        if notification.request.identifier == dailyReminderIdentifier {

            // Check if app is currently active (user is using the app)
            let appState = UIApplication.shared.applicationState

            if appState == .active {
                // App is in use, don't show the notification
                print("🚫 App is active - suppressing daily reminder notification")
                completionHandler([]) // Don't show notification
                return
            }
        }

        // For all other cases, show the notification with sound and banner
        completionHandler([.banner, .sound, .badge])
    }

    // Called when user taps on the notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {

        let notification = response.notification

        // Handle daily reminder notification tap
        if notification.request.identifier == dailyReminderIdentifier {
            print("📚 User tapped daily reading reminder - opening app")

            // Clear the badge
            UIApplication.shared.applicationIconBadgeNumber = 0
            Task {
                if #available(iOS 16.0, *) {
                    try? await UNUserNotificationCenter.current().setBadgeCount(0)
                }
            }

            // Here you could add analytics or navigate to a specific view
            // For example, navigate to the home view or library
        }

        completionHandler()
    }
}
