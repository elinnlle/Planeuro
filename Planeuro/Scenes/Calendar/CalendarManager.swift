//
//  CalendarManager.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 08.04.2025.
//

import Foundation
import EventKit

final class CalendarManager {
    
    static let shared = CalendarManager()
    private let eventStore: EKEventStore = EKEventStore()
    
    private init() {}
    
    // MARK: - Запрос доступа
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    // MARK: - Создание события
    
    func createEvent(for task: Tasks, completion: @escaping (Bool, String?) -> Void) {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            guard let self = self else {
                DispatchQueue.main.async { completion(false, nil) }
                return
            }
            guard granted, error == nil else {
                DispatchQueue.main.async { completion(false, nil) }
                return
            }
            
            let event = EKEvent(eventStore: self.eventStore)
            event.title = task.title
            event.startDate = task.startDate
            event.endDate = task.endDate
            event.location = task.address
            event.notes = task.categoryTitle
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            
            do {
                try self.eventStore.save(event, span: .thisEvent, commit: true)
                DispatchQueue.main.async {
                    completion(true, event.eventIdentifier)
                }
            } catch let saveError {
                print("Ошибка сохранения события: \(saveError.localizedDescription)")
                DispatchQueue.main.async { completion(false, nil) }
            }
        }
    }
    
    // MARK: - Обновление события
    
    func updateEvent(for task: Tasks, eventIdentifier: String, completion: @escaping (Bool, String?) -> Void) {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            guard let self = self else {
                DispatchQueue.main.async { completion(false, nil) }
                return
            }
            guard granted, error == nil else {
                DispatchQueue.main.async { completion(false, nil) }
                return
            }
            
            // Ищем событие в календаре
            if let event = self.eventStore.event(withIdentifier: eventIdentifier) {
                event.title = task.title
                event.startDate = task.startDate
                event.endDate = task.endDate
                event.location = task.address
                event.notes = task.categoryTitle
                
                do {
                    try self.eventStore.save(event, span: .thisEvent, commit: true)
                    DispatchQueue.main.async {
                        completion(true, event.eventIdentifier)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
    }
    
    // MARK: - Удаление события
    
    func deleteEvent(withIdentifier eventIdentifier: String, completion: @escaping (Bool) -> Void) {
        if let event = eventStore.event(withIdentifier: eventIdentifier) {
            do {
                try eventStore.remove(event, span: .thisEvent, commit: true)
                DispatchQueue.main.async { completion(true) }
            } catch let error {
                print("Ошибка удаления события: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(false) }
            }
        } else {
            DispatchQueue.main.async { completion(false) }
        }
    }
    
    // MARK: - Получение событий
    
    func fetchEvents(startDate: Date, endDate: Date, completion: @escaping ([EKEvent]) -> Void) {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        DispatchQueue.main.async {
            completion(events)
        }
    }
}
