//
//  SettingsInteractor.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.03.2025.
//

// SettingsInteractor.swift
import Foundation

class SettingsInteractor {
    private let nameKey  = "userName"
    private let emailKey = "userEmail"
    private let wakeKey  = "wakeUpTime"
    private let sleepKey = "sleepTime"

    private let defaultWakeUpHour   = 10
    private let defaultWakeUpMinute = 0
    private let defaultSleepHour    = 22
    private let defaultSleepMinute  = 0

    private(set) var wakeUpTime: Date
    private(set) var sleepTime: Date
    let presenter: SettingsPresenter

    init(presenter: SettingsPresenter) {
        let defaults = UserDefaults.standard
        let savedName  = defaults.string(forKey: nameKey)  ?? "Имя пользователя"
        let savedEmail = defaults.string(forKey: emailKey) ?? "name@pochta.ru"
        presenter.presentProfile(name: savedName, email: savedEmail)

        self.presenter = presenter
        let now = Date()
        let cal = Calendar.current

        if let saved = UserDefaults.standard.object(forKey: wakeKey) as? Date {
            wakeUpTime = saved
        } else {
            wakeUpTime = cal.date(
                bySettingHour: defaultWakeUpHour,
                minute: defaultWakeUpMinute,
                second: 0,
                of: now
            )!
        }

        if let saved = UserDefaults.standard.object(forKey: sleepKey) as? Date {
            sleepTime = saved
        } else {
            sleepTime = cal.date(
                bySettingHour: defaultSleepHour,
                minute: defaultSleepMinute,
                second: 0,
                of: now
            )!
        }
    }

    func updateWakeUpTime(to date: Date) {
        wakeUpTime = date
        UserDefaults.standard.set(date, forKey: wakeKey)
        presenter.presentWakeUpTime(date: date)
    }

    func updateSleepTime(to date: Date) {
        sleepTime = date
        UserDefaults.standard.set(date, forKey: sleepKey)
        presenter.presentSleepTime(date: date)
    }
}
