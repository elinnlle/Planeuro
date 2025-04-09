//
//  CalendarEventModel.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 08.04.2025.
//

import Foundation

/// Модель, описывающая событие для синхронизации с календарём.
struct CalendarEventModel {
    let title: String
    let startDate: Date
    let endDate: Date
    let note: String?
}
