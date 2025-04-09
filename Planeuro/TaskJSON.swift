//
//  TaskJSON.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 01.04.2025.
//

import Foundation

// Модель для парсинга JSON
struct TaskJSON: Codable {
    let title: String
    let startDate: String?
    let endDate: String?
    let address: String
    let timeTravel: Int16?
    let categoryColor: String
    let categoryTitle: String?
    let status: Int16?
    let type: Int16?
}

// Пример функции для сохранения задач из JSON
func saveTasksFromJSON() {
    let jsonString = ""
    
    guard let jsonData = jsonString.data(using: .utf8) else {
        print("Ошибка конвертации строки в Data")
        return
    }
    
    do {
        let tasksFromJSON = try JSONDecoder().decode([TaskJSON].self, from: jsonData)
        let service = TasksService()
        
        let isoFormatter = ISO8601DateFormatter()
        
        for taskJSON in tasksFromJSON {
            // Парсинг startDate
            let startDate: Date
            if let startDateStr = taskJSON.startDate, let parsedStart = isoFormatter.date(from: startDateStr) {
                startDate = parsedStart
            } else {
                startDate = Date()
            }
            
            // Парсинг endDate
            let endDate: Date
            if let endDateStr = taskJSON.endDate, let parsedEnd = isoFormatter.date(from: endDateStr) {
                endDate = parsedEnd
            } else {
                // Если endDate отсутствует, устанавливаем его как startDate + 1 час
                endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) ?? Date()
            }
            
            // Определяем статус задачи
            let status: TaskStatus
            if let statusRaw = taskJSON.status, let parsedStatus = TaskStatus(rawValue: statusRaw) {
                status = parsedStatus
            } else {
                status = .active
            }
            
            // Определяем тип задачи
            let taskType: TaskType
            if let typeRaw = taskJSON.type, let parsedType = TaskType(rawValue: typeRaw) {
                taskType = parsedType
            } else {
                taskType = .userDefined
            }
            
            // Определяем время на дорогу; если поле отсутствует – по умолчанию 0
            let travelTime: Int = Int(taskJSON.timeTravel ?? 0)
            
            // Добавляем задачу в базу данных (не создаём событие в календаре автоматически)
            service.addNewTask(
                title: taskJSON.title,
                startDate: startDate,
                endDate: endDate,
                address: taskJSON.address,
                timeTravel: travelTime,
                categoryColor: taskJSON.categoryColor,
                categoryTitle: taskJSON.categoryTitle,
                status: status,
                taskType: taskType
            )
        }
        
        print("Задачи успешно сохранены в базе данных.")
    } catch {
        print("Ошибка парсинга JSON: \(error)")
    }
}
