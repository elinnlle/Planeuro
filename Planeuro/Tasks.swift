//
//  Tasks.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import Foundation
import EventKit
import UIKit

struct Tasks: Decodable, Equatable {
    var title: String
    var startDate: Date
    var endDate: Date
    var address: String
    var timeTravel: Int
    var categoryColorName: String
    var categoryTitle: String
    var status: TaskStatus
    let type: TaskType
    var eventIdentifier: String?
    var reminderOffsets: [TimeInterval]
    var reminderNotificationIDs: [String]
    
    init(title: String,
         startDate: Date,
         endDate: Date,
         address: String,
         timeTravel: Int,
         categoryColorName: String,
         categoryTitle: String,
         status: TaskStatus,
         type: TaskType,
         eventIdentifier: String? = nil,
         reminderOffsets: [TimeInterval] = [],
         reminderNotificationIDs: [String] = []) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.address = address
        self.timeTravel = timeTravel
        self.categoryColorName = categoryColorName
        self.categoryTitle = categoryTitle
        self.status = status
        self.type = type
        self.eventIdentifier = eventIdentifier
        self.reminderOffsets = reminderOffsets
        self.reminderNotificationIDs = reminderNotificationIDs
    }
    
    // Вычисляемое свойство для UIColor
    var categoryColor: UIColor {
        switch categoryColorName.lowercased() {
        case "red":      return .systemRed
        case "orange":   return .systemOrange
        case "yellow":   return .systemYellow
        case "green":    return .systemGreen
        case "blue":     return .systemBlue
        case "purple":   return .systemPurple
        case "gray":     return .systemGray
        case "brown":    return .brown
        default:         return .white
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case startDate
        case endDate
        case address
        case timeTravel
        case categoryColorName = "categoryColor"
        case categoryTitle
        case status
        case type
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        
        let startDateString = try container.decode(String.self, forKey: .startDate)
        let endDateString   = try container.decode(String.self, forKey: .endDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let sDate = formatter.date(from: startDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .startDate, in: container,
                debugDescription: "Неверный формат даты для startDate"
            )
        }
        guard let eDate = formatter.date(from: endDateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .endDate, in: container,
                debugDescription: "Неверный формат даты для endDate"
            )
        }
        self.startDate = sDate
        self.endDate   = eDate
        
        self.address            = try container.decode(String.self, forKey: .address)
        self.timeTravel         = try container.decodeIfPresent(Int.self, forKey: .timeTravel) ?? 0
        self.categoryColorName  = try container.decode(String.self, forKey: .categoryColorName)
        self.categoryTitle      = try container.decodeIfPresent(String.self, forKey: .categoryTitle) ?? ""
        
        let statusRaw = try container.decode(Int16.self, forKey: .status)
        self.status   = TaskStatus(rawValue: statusRaw) ?? .active
        
        let typeRaw = try container.decode(Int16.self, forKey: .type)
        self.type   = TaskType(rawValue: typeRaw) ?? .userDefined
        
        self.eventIdentifier = nil
        
        // Новые поля
        self.reminderOffsets          = []
        self.reminderNotificationIDs  = []
    }
}

enum TaskType: Int16, Decodable {
    case userDefined       = 0 // Задача создана пользователем
    case aiRecommendation  = 1 // Рекомендация ИИ
}

enum TaskStatus: Int16, Decodable {
    case active     = 0
    case completed  = 1
    case overdue    = 2
}

extension Tasks {
    /// Инициализирует задачу на основе события календаря.
    init(from event: EKEvent) {
        self.title     = event.title ?? "Без названия"
        self.startDate = event.startDate ?? .init()
        self.endDate   = event.endDate   ?? .init()
        self.address   = event.location  ?? ""
        self.timeTravel = 0
        self.categoryColorName = ""
        self.categoryTitle     = ""
        self.status    = .active
        self.type      = .userDefined
        self.eventIdentifier = event.eventIdentifier
        self.reminderOffsets         = []
        self.reminderNotificationIDs = []
    }
}
