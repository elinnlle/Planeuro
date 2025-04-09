//
//  CalendarManaging.swift
//  Planeuro
//
//  Created by Ваше Имя on 2025-04-13
//

import Foundation
import EventKit

/// Протокол, описывающий базовые функции работы с календарём.
protocol CalendarManaging {
    /// Запрашивает у пользователя доступ к календарям.
    func requestAccess(completion: @escaping (Bool) -> Void)
    
    /// Создаёт событие на основе модели.
    func create(eventModel: CalendarEventModel, completion: @escaping (Bool, String?) -> Void)
    
    /// Получает события из календаря за указанный интервал времени.
    func fetchEvents(startDate: Date, endDate: Date, completion: @escaping ([EKEvent]) -> Void)
    
    /// Удаляет событие по его идентификатору.
    func delete(eventIdentifier: String, completion: @escaping (Bool) -> Void)
}

