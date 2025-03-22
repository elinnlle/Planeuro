//
//  SettingsInteractor.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.03.2025.
//

import UIKit

class SettingsInteractor {
    
    private let defaultWakeUpHour = 10
    private let defaultWakeUpMinute = 0
    private let defaultSleepHour = 22
    private let defaultSleepMinute = 0
    
    private(set) var wakeUpTime: Date
    private(set) var sleepTime: Date
    let presenter: SettingsPresenter
    
    init(presenter: SettingsPresenter) {
        self.presenter = presenter
        let now = Date()
        // Создаём время по умолчанию
        self.wakeUpTime = Calendar.current.date(bySettingHour: defaultWakeUpHour, minute: defaultWakeUpMinute, second: 0, of: now)!
        self.sleepTime = Calendar.current.date(bySettingHour: defaultSleepHour, minute: defaultSleepMinute, second: 0, of: now)!
    }
    
    func updateWakeUpTime(to date: Date) {
        wakeUpTime = date
        presenter.presentWakeUpTime(date: date)
    }
    
    func updateSleepTime(to date: Date) {
        sleepTime = date
        presenter.presentSleepTime(date: date)
    }
}
