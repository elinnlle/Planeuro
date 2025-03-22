//
//  SettingsView.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.03.2025.
//

import UIKit

protocol SettingsView: AnyObject {
    func displayWakeUpTime(_ time: String)
    func displaySleepTime(_ time: String)
}
