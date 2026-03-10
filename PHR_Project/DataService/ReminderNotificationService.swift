import Foundation
import UserNotifications

final class ReminderNotificationService {
    static let shared = ReminderNotificationService()

    private enum Keys {
        static let notificationsEnabled = "notifications_enabled"
    }

    private enum IDs {
        static let breakfast = "meal.breakfast"
        static let lunch = "meal.lunch"
        static let dinner = "meal.dinner"
        static let water10 = "water.10"
        static let water12 = "water.12"
        static let water14 = "water.14"
        static let water16 = "water.16"
        static let water18 = "water.18"
        static let water20 = "water.20"

        static let all = [
            breakfast,
            lunch,
            dinner,
            water10,
            water12,
            water14,
            water16,
            water18,
            water20,
        ]
    }

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func isEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: Keys.notificationsEnabled)
    }

    func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.notificationsEnabled)
    }

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            granted,
            _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func scheduleDefaultReminders() {
        center.removePendingNotificationRequests(withIdentifiers: IDs.all)

        scheduleReminder(
            id: IDs.breakfast,
            title: "Breakfast reminder",
            body: "Log your breakfast to keep your meal record up to date.",
            hour: 9,
            minute: 0
        )

        scheduleReminder(
            id: IDs.lunch,
            title: "Lunch reminder",
            body: "Time to log your lunch.",
            hour: 13,
            minute: 30
        )

        scheduleReminder(
            id: IDs.dinner,
            title: "Dinner reminder",
            body: "Don't forget to log your dinner.",
            hour: 20,
            minute: 0
        )

        scheduleReminder(
            id: IDs.water10,
            title: "Hydration reminder",
            body: "Drink a glass of water and update your water intake.",
            hour: 10,
            minute: 0
        )
        scheduleReminder(
            id: IDs.water12,
            title: "Hydration reminder",
            body: "Time for water. Stay hydrated.",
            hour: 12,
            minute: 0
        )
        scheduleReminder(
            id: IDs.water14,
            title: "Hydration reminder",
            body: "Take a quick water break.",
            hour: 14,
            minute: 0
        )
        scheduleReminder(
            id: IDs.water16,
            title: "Hydration reminder",
            body: "Log another glass of water.",
            hour: 16,
            minute: 0
        )
        scheduleReminder(
            id: IDs.water18,
            title: "Hydration reminder",
            body: "Keep your hydration streak going.",
            hour: 18,
            minute: 0
        )
        scheduleReminder(
            id: IDs.water20,
            title: "Hydration reminder",
            body: "Last water check-in for today.",
            hour: 20,
            minute: 0
        )
    }

    func cancelAllReminders() {
        center.removePendingNotificationRequests(withIdentifiers: IDs.all)
    }

    func refreshRemindersIfNeededOnLaunch() {
        guard isEnabled() else { return }
        scheduleDefaultReminders()
    }

    private func scheduleReminder(
        id: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int
    ) {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }
}
