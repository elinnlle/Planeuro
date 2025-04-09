//
//  Subtask.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 06.04.2025.
//

import UIKit

struct Subtask: Codable, Equatable {
    let title: String
    let start: Date
    let end: Date
    let location: String
    let travelTime: Int
    let categoryColor: String
    let categoryName: String
    let status: String
    let taskType: String
    let difficulty: String

    enum CodingKeys: String, CodingKey {
        case title           = "название подзадачи"
        case start           = "начало подзадачи"
        case end             = "конец подзадачи"
        case location        = "место"
        case travelTime      = "время на дорогу"
        case categoryColor   = "цвет категории"
        case categoryName    = "название категории"
        case status          = "статус"
        case taskType        = "тип задачи"
        case difficulty      = "сложность"
    }

    /// Для кнопки «плюс»
    init(title: String) {
        self.title         = title
        self.start         = Date()
        self.end           = Date()
        self.location      = ""
        self.travelTime    = 0
        self.categoryColor = ""
        self.categoryName  = ""
        self.status        = "active"
        self.taskType      = "userDefined"
        self.difficulty    = "простая"
    }

    /// Полный конструктор для конвертации из Task
    init(title: String,
         start: Date,
         end: Date,
         location: String,
         travelTime: Int,
         categoryColor: String,
         categoryName: String,
         status: String,
         taskType: String,
         difficulty: String)
    {
        self.title         = title
        self.start         = start
        self.end           = end
        self.location      = location
        self.travelTime    = travelTime
        self.categoryColor = categoryColor
        self.categoryName  = categoryName
        self.status        = status
        self.taskType      = taskType
        self.difficulty    = difficulty
    }
}
