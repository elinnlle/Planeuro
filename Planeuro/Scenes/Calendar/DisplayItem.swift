//
//  DisplayItem.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 08.04.2025.
//

import Foundation

// Все виды ячеек в расписании
enum DisplayItem {
    case fullDay(task: Tasks)
    case greetingMorning(time: Date, taskCount: Int)
    case greetingNight(time: Date)
    case travel(time: Date, duration: Int)
    case task(time: Date, task: Tasks)
    case gap(start: Date, end: Date)
}
