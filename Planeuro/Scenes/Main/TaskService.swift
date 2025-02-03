//
//  TaskService.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import Foundation

// Управление задачами
class TaskService {
    // Массив задач
    private var tasks: [Task] = [
        Task(title: "Стоматолог", categoryColor: .green, address: "ул. Ленина, 1", date: "Сегодня, 12:00 - 13:00", isActive: true),
        Task(title: "Алгосы", categoryColor: .red, address: "ул. Пушкина, 2", date: "Завтра, 16:00 - 18:00", isActive: true),
        Task(title: "Кинотеатр", categoryColor: .purple, address: "ул. Мира, 3", date: "Завтра, 20:00 - 21:30", isActive: true),
        Task(title: "ABC", categoryColor: .red, address: "ул. Гагарина, 4", date: "22 ноября, 15:00 - 17:00", isActive: true),
        Task(title: "День рождения Лизы", categoryColor: .yellow, address: "ул. Садовая, 5", date: "23 ноября, 20:00 - 23:00", isActive: true),
        Task(title: "Позвонить бабушке", categoryColor: .gray, address: "ул. Советская, 6", date: "24 ноября, 15:00 - 16:00", isActive: true),
        Task(title: "Алгосы", categoryColor: .red, address: "ул. Пушкина, 2", date: "Завтра, 16:00 - 18:00", isActive: true),
        Task(title: "Кинотеатр", categoryColor: .purple, address: "ул. Мира, 3", date: "Завтра, 20:00 - 21:30", isActive: true),
        Task(title: "ABC", categoryColor: .red, address: "ул. Гагарина, 4", date: "22 ноября, 15:00 - 17:00", isActive: true),
        Task(title: "День рождения Лизы", categoryColor: .yellow, address: "ул. Садовая, 5", date: "23 ноября, 20:00 - 23:00", isActive: true),
        Task(title: "Позвонить бабушке", categoryColor: .gray, address: "ул. Советская, 6", date: "24 ноября, 15:00 - 16:00", isActive: true)
    ]
    
    // Метод для получения всех задач
    func getAllTasks() -> [Task] {
        return tasks
    }
    
    // Метод для обновления существующей задачи
    func updateTask(_ task: Task) {
        // Находит индекс задачи по заголовку и обновляет её
        if let index = tasks.firstIndex(where: { $0.title == task.title }) {
            tasks[index] = task
        }
    }
    
    // Метод для удаления задачи
    func deleteTask(_ task: Task) {
        // Удаляет задачу из массива по заголовку
        tasks.removeAll { $0.title == task.title }
    }
}
