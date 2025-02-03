//
//  TaskInteractor.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import Foundation

// Взаимодействие с сервисом задач
class TaskInteractor {
    private let taskService = TaskService()
    
    // Метод для получения всех задач
    func fetchTasks() -> [Task] {
        return taskService.getAllTasks()
    }
    
    // Метод для завершения задачи
    func completeTask(_ task: Task) {
        var updatedTask = task
        updatedTask.isActive = false
        taskService.updateTask(updatedTask)
    }
    
    // Метод для удаления задачи
    func deleteTask(_ task: Task) {
        taskService.deleteTask(task)
    }
}
