//
//  AppDelegate.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 14.01.2025.
//

import UIKit
import CoreData
import UserNotifications
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    // MARK: — Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PlaneuroDataModel")
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
        return container
    }()
    
    func saveContext() {
        let ctx = persistentContainer.viewContext
        if ctx.hasChanges {
            do {
                try ctx.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved Core Data error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: — App lifecycle

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1) Window и root VC
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainVC = MainViewController()
        let nav = UINavigationController(rootViewController: mainVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        // 2) Доступ к календарю
        CalendarManager.shared.requestAccess { granted in
            print(granted ? "Доступ к календарю получен" : "Доступ к календарю не предоставлен")
        }
        
        // 3) Локальные уведомления
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Разрешение на уведомления получено")
                // Только если включены push-уведомления
                if UserDefaults.standard.bool(forKey: "pushNotificationsEnabled") {
                    DispatchQueue.main.async {
                        let service = TasksService()
                        let allTasks = service.getAllTasks()
                        allTasks.forEach { task in
                            let newIDs = NotificationManager.shared.scheduleLocalNotifications(for: task)
                            service.updateReminderIDs(for: task, with: newIDs)
                        }
                    }
                }
            } else {
                print("Уведомления не разрешены: \(String(describing: error))")
            }
        }
        
        // 4) Регистрируем BG-таску для e-mail-напоминаний
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.planeuro.emailReminder",
            using: nil
        ) { task in
            self.handleEmailReminder(task: task as! BGProcessingTask)
        }

        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Планируем BG-задачу только если включены e-mail-уведомления
        guard UserDefaults.standard.bool(forKey: "emailNotificationsEnabled") else { return }
        let request = BGProcessingTaskRequest(identifier: "com.planeuro.emailReminder")
        request.earliestBeginDate = Date().addingTimeInterval(60)
        request.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Не удалось зарегистрировать BGTask: \(error)")
        }
    }
    
    // MARK: — Обработка bg-таски

    private func handleEmailReminder(task: BGProcessingTask) {
        // Если e-mail-уведомления выключены — сразу завершаем
        guard UserDefaults.standard.bool(forKey: "emailNotificationsEnabled") else {
            task.setTaskCompleted(success: true)
            return
        }
        
        // 1) Получаем e-mail из Keychain
        let userEmail: String
        do {
            if let email = try KeychainHelper.loadPassword(for: "userEmail"), !email.isEmpty {
                userEmail = email
            } else {
                print("E-mail пользователя не найден в Keychain")
                task.setTaskCompleted(success: true)
                return
            }
        } catch {
            print("Ошибка загрузки e-mail из Keychain:", error)
            task.setTaskCompleted(success: true)
            return
        }
        
        // 2) Загружаем задачи и фильтруем по времени напоминания
        let tasks = TaskInteractor().fetchTasks()
        let now = Date()
        let group = DispatchGroup()
        
        for t in tasks {
            for offset in t.reminderOffsets {
                let fireDate = t.startDate.addingTimeInterval(-offset)
                // Допустимый диапазон ±1 минута
                if abs(fireDate.timeIntervalSince(now)) < 60 {
                    group.enter()
                    Task {
                        do {
                            try await MailService.shared.sendTaskReminder(to: userEmail, task: t)
                        } catch {
                            print("Ошибка email-напоминания для \(t.title):", error)
                        }
                        group.leave()
                    }
                }
            }
        }
        
        task.expirationHandler = {
            // если время bg-таски истекло
        }
        group.notify(queue: .global()) {
            task.setTaskCompleted(success: true)
            // Планируем следующий запуск только если включены e-mail-уведомления
            self.scheduleEmailBackgroundTask()
        }
    }
    
    // MARK: — UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Показываем баннер и звук даже если приложение активно
        completionHandler([.banner, .sound])
    }
    
    // MARK: — Помощник для BGProcessingTaskRequest

    private func scheduleEmailBackgroundTask() {
        guard UserDefaults.standard.bool(forKey: "emailNotificationsEnabled") else { return }
        let request = BGProcessingTaskRequest(identifier: "com.planeuro.emailReminder")
        request.earliestBeginDate = Date().addingTimeInterval(60)
        request.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Не удалось зарегистрировать BGTask:", error)
        }
    }
}
