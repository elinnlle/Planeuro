//
//  TaskPresenter.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import Foundation

protocol TaskPresenterDelegate: AnyObject {
    func updateTasks(_ tasks: [Tasks])
}

class TaskPresenter {
    private let taskInteractor = TaskInteractor()
    weak var delegate: TaskPresenterDelegate?
    
    // Загрузка всех задач
    func loadTasks() {
        taskInteractor.updateOverdueTasks()
        let tasks = taskInteractor.fetchTasks()
        delegate?.updateTasks(tasks)
    }
    
    // Загрузка задач для конкретной даты
    func loadTasks(for date: Date) {
        taskInteractor.updateOverdueTasks()
        let tasks = taskInteractor.fetchTasks(for: date)
        delegate?.updateTasks(tasks)
    }
    
    // Завершение задачи
    func completeTask(_ task: Tasks) {
        taskInteractor.completeTask(task)
        delegate?.updateTasks(taskInteractor.fetchTasks())
    }
    
    // Удаление задачи
    func deleteTask(_ task: Tasks) {
        taskInteractor.deleteTask(task)
        delegate?.updateTasks(taskInteractor.fetchTasks())
    }
}
