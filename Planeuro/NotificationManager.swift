//
//  NotificationManager.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 05.04.2025.
//

import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    /// Планирует локальные уведомления и возвращает массив новых идентификаторов
    @discardableResult
    func scheduleLocalNotifications(for task: Tasks) -> [String] {
        guard UserDefaults.standard.bool(forKey: "pushNotificationsEnabled") else {
            return []
        }
        let center = UNUserNotificationCenter.current()
        // 1) Удаляем старые
        center.removePendingNotificationRequests(withIdentifiers: task.reminderNotificationIDs)

        var newIDs: [String] = []
        let calendar = Calendar.current
        let now = Date()

        for offset in task.reminderOffsets {
            let fireDate = task.startDate.addingTimeInterval(-offset)
            guard fireDate > now else { continue }

            // 2) Контент
            let content = UNMutableNotificationContent()
            content.title = "Напоминание: \(task.title)"

            // Определяем, что за день
            let dateString: String
            if calendar.isDateInToday(task.startDate) {
                dateString = "сегодня"
            } else if calendar.isDateInTomorrow(task.startDate) {
                dateString = "завтра"
            } else {
                dateString = task.startDate.formatted(date: .abbreviated, time: .omitted)
            }
            let timeString = task.startDate.formatted(date: .omitted, time: .shortened)

            content.body = "Событие начнётся \(dateString) в \(timeString)"
            content.sound = .default

            // 3) Триггер
            let comps = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

            // 4) Запрос
            let id = UUID().uuidString
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request) { error in
                if let e = error {
                    print("Ошибка планирования локального уведомления:", e)
                }
            }
            newIDs.append(id)
        }

        return newIDs
    }
}
