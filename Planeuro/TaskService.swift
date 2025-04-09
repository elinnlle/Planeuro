//
//  TasksService.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import UIKit
import CoreData
import UserNotifications
import BackgroundTasks

class TasksService {
    // Контекст Core Data, берём из AppDelegate
    private let context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: — Получение задач
    
    func getAllTasks() -> [Tasks] {
        updateOverdueTasks()
        let request: NSFetchRequest<PlaneuroTaskEntity> = PlaneuroTaskEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.task }
        } catch {
            print("Ошибка при загрузке задач: \(error)")
            return []
        }
    }
    
    func getTasks(for date: Date) -> [Tasks] {
        updateOverdueTasks()
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: date)
        guard let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        let request: NSFetchRequest<PlaneuroTaskEntity> = PlaneuroTaskEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "(startDate < %@) AND (endDate >= %@)",
            endOfDay as NSDate, startOfDay as NSDate
        )
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.task }
        } catch {
            print("Ошибка при загрузке задач: \(error)")
            return []
        }
    }
    
    // MARK: — Сохранение / Удаление
    
    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения контекста: \(error)")
        }
    }
    
    func updateReminderIDs(for task: Tasks, with newIDs: [String]) {
        let request: NSFetchRequest<PlaneuroTaskEntity> = PlaneuroTaskEntity.fetchRequest()
        if let eid = task.eventIdentifier, !eid.isEmpty {
            request.predicate = NSPredicate(format: "eventIdentifier == %@", eid)
        } else {
            request.predicate = NSPredicate(format: "title == %@", task.title)
        }
        if let entity = (try? context.fetch(request))?.first {
            entity.reminderNotificationID1 = newIDs.first
            entity.reminderNotificationID2 = newIDs.dropFirst().first
            saveContext()
        }
    }
    
    func addNewTask(
        title: String,
        startDate: Date,
        endDate: Date,
        address: String?,
        timeTravel: Int,
        categoryColor: String?,
        categoryTitle: String?,
        status: TaskStatus,
        taskType: TaskType,
        eventIdentifier: String? = nil,
        reminderOffsets: [TimeInterval] = []
    ) {
        // 1) Сохраняем в Core Data
        let e = PlaneuroTaskEntity(context: context)
        e.title = title
        e.startDate = startDate
        e.endDate = endDate
        e.address = address
        e.timeTravel = Int16(timeTravel)
        e.categoryColor = categoryColor
        e.categoryTitle = categoryTitle
        e.status = status.rawValue
        e.type = taskType.rawValue
        e.eventIdentifier = eventIdentifier
        e.reminderOffset1 = reminderOffsets.count > 0 ? reminderOffsets[0] : 0
        e.reminderOffset2 = reminderOffsets.count > 1 ? reminderOffsets[1] : 0
        saveContext()
        
        // 2) Планируем локальные уведомления (если включены)
        let taskStruct = Tasks(
            title: title,
            startDate: startDate,
            endDate: endDate,
            address: address ?? "",
            timeTravel: timeTravel,
            categoryColorName: categoryColor ?? "",
            categoryTitle: categoryTitle ?? "",
            status: status,
            type: taskType,
            eventIdentifier: eventIdentifier,
            reminderOffsets: reminderOffsets,
            reminderNotificationIDs: []
        )
        var newIDs: [String] = []
        if UserDefaults.standard.bool(forKey: "pushNotificationsEnabled") {
            newIDs = NotificationManager.shared.scheduleLocalNotifications(for: taskStruct)
        }
        
        // 3) Сохраняем новые IDs
        e.reminderNotificationID1 = newIDs.first
        e.reminderNotificationID2 = newIDs.dropFirst().first
        saveContext()
        
        // 4) Регистрируем BG-задачу для e-mail напоминаний (если включены)
        if UserDefaults.standard.bool(forKey: "emailNotificationsEnabled") {
            scheduleEmailBackgroundTask()
        }
    }
    
    func updateTask(_ task: Tasks, originalTitle: String? = nil) {
        // 1) Обновляем сущность
        let request: NSFetchRequest<PlaneuroTaskEntity> = PlaneuroTaskEntity.fetchRequest()
        if let eid = task.eventIdentifier, !eid.isEmpty {
            request.predicate = NSPredicate(format: "eventIdentifier == %@", eid)
        } else {
            let titleKey = originalTitle ?? task.title
            request.predicate = NSPredicate(format: "title == %@", titleKey)
        }
        
        do {
            let results = try context.fetch(request)
            let e: PlaneuroTaskEntity = results.first ?? PlaneuroTaskEntity(context: context)
            
            e.title = task.title
            e.startDate = task.startDate
            e.endDate = task.endDate
            e.address = task.address
            e.timeTravel = Int16(task.timeTravel)
            e.categoryColor = task.categoryColorName
            e.categoryTitle = task.categoryTitle
            
            if e.status == TaskStatus.overdue.rawValue
               && task.endDate > Date()
               && task.status != .completed {
                e.status = TaskStatus.active.rawValue
            } else {
                e.status = task.status.rawValue
            }
            
            e.type = task.type.rawValue
            e.eventIdentifier = task.eventIdentifier
            e.reminderOffset1 = task.reminderOffsets.count > 0 ? task.reminderOffsets[0] : 0
            e.reminderOffset2 = task.reminderOffsets.count > 1 ? task.reminderOffsets[1] : 0
            e.reminderNotificationID1 = nil
            e.reminderNotificationID2 = nil
            
            saveContext()
        } catch {
            print("Ошибка обновления задачи: \(error)")
        }
        
        // 2) Перепланируем локальные уведомления (если включены)
        var newIDs: [String] = []
        if UserDefaults.standard.bool(forKey: "pushNotificationsEnabled") {
            newIDs = NotificationManager.shared.scheduleLocalNotifications(for: task)
        }
        updateReminderIDs(for: task, with: newIDs)
        
        // 3) Регистрируем BG-задачу для e-mail напоминаний (если включены)
        if UserDefaults.standard.bool(forKey: "emailNotificationsEnabled") {
            scheduleEmailBackgroundTask()
        }
    }
    
    func deleteTask(_ task: Tasks) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: task.reminderNotificationIDs
        )
        let request: NSFetchRequest<PlaneuroTaskEntity> = PlaneuroTaskEntity.fetchRequest()
        if let eid = task.eventIdentifier, !eid.isEmpty {
            request.predicate = NSPredicate(format: "eventIdentifier == %@", eid)
        } else {
            request.predicate = NSPredicate(format: "title == %@", task.title)
        }
        do {
            let entities = try context.fetch(request)
            entities.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("Ошибка удаления задачи: \(error)")
        }
    }
    
    // MARK: — Вспомогательные методы
    
    func updateOverdueTasks() {
        let request: NSFetchRequest<PlaneuroTaskEntity> = PlaneuroTaskEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "status != %d AND endDate < %@",
            TaskStatus.completed.rawValue, Date() as CVarArg
        )
        do {
            let entities = try context.fetch(request)
            entities.forEach { $0.status = TaskStatus.overdue.rawValue }
            saveContext()
        } catch {
            print("Ошибка обновления статуса просроченных задач: \(error)")
        }
    }
    
    func removeCategoryFromTasks(color: String) {
        let request: NSFetchRequest<PlaneuroTaskEntity> = PlaneuroTaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "categoryColor ==[c] %@", color)
        do {
            let entities = try context.fetch(request)
            entities.forEach {
                $0.categoryColor = ""
                $0.categoryTitle = ""
            }
            saveContext()
        } catch {
            print("Ошибка при удалении категории из задач: \(error)")
        }
    }
    
    /// Регистрирует BGProcessingTaskRequest для e-mail напоминаний
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
