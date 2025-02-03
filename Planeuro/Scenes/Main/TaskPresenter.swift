//
//  TaskPresenter.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import Foundation

// Протокол делегата для обновления списка задач
protocol TaskPresenterDelegate: AnyObject {
    func updateTasks(_ tasks: [Task])
}

// Логика управления задачами
class TaskPresenter {
    private let taskInteractor = TaskInteractor()
    weak var delegate: TaskPresenterDelegate?
    
    // Метод для загрузки задач
    func loadTasks() {
        let tasks = taskInteractor.fetchTasks()
        delegate?.updateTasks(tasks)
    }
    
    // Метод для завершения задачи
    func completeTask(_ task: Task) {
        taskInteractor.completeTask(task)
        loadTasks()
    }
    
    // Метод для удаления задачи
    func deleteTask(_ task: Task) {
        taskInteractor.deleteTask(task)
        loadTasks()
    }
}
