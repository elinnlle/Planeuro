//
//  TaskInteractor.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import Foundation

class TaskInteractor {
    private let taskService = TasksService()
    
    func fetchTasks() -> [Tasks] {
        taskService.updateOverdueTasks()
        return taskService.getAllTasks()
    }
    
    func fetchTasks(for date: Date) -> [Tasks] {
        taskService.updateOverdueTasks()
        return taskService.getTasks(for: date)
    }
    
    func completeTask(_ task: Tasks) {
        let updated = Tasks(
            title: task.title,
            startDate: task.startDate,
            endDate: task.endDate,
            address: task.address,
            timeTravel: task.timeTravel,
            categoryColorName: task.categoryColorName,
            categoryTitle: task.categoryTitle,
            status: .completed,
            type: task.type,
            eventIdentifier: task.eventIdentifier,
            reminderOffsets: task.reminderOffsets,
            reminderNotificationIDs: task.reminderNotificationIDs
        )
        taskService.updateTask(updated)
    }
    
    func deleteTask(_ task: Tasks) {
        taskService.deleteTask(task)
    }
    
    func updateOverdueTasks() {
        taskService.updateOverdueTasks()
    }
}
