//
//  SettingsPresenter.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.03.2025.
//

import UIKit

class SettingsPresenter {
    weak var view: SettingsView?
    
    func presentWakeUpTime(date: Date) {
        let formattedTime = "Подъём \(date.formatted(date: .omitted, time: .shortened))"
        view?.displayWakeUpTime(formattedTime)
    }
    
    func presentSleepTime(date: Date) {
        let formattedTime = "Отход ко сну \(date.formatted(date: .omitted, time: .shortened))"
        view?.displaySleepTime(formattedTime)
    }
}
