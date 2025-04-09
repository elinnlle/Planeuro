//
//  AddTaskView.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 29.04.2025.
//

import Foundation

protocol AddTaskView: AnyObject {
    func displayNewMessage(_ message: Message)
    func openEditTask(_ task: Tasks)
    func openSubtasksView(with json: String, onAccept: @escaping (String) -> Void)
    func showLoading()
    func hideLoading()
    func showYesNoButtons()
    func hideYesNoButtons()
}
