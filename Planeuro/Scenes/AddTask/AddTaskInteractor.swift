//
//  AddTaskInteractor.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.03.2025.
//

import Foundation

protocol AddTaskInteractorProtocol {
    func addInitialMessage()
    func addRepeatMessage()
    func addMessage(text: String, isUser: Bool)
}

protocol AddTaskInteractorOutput: AnyObject {
    func didAddMessage(_ message: Message)
}

class AddTaskInteractor: AddTaskInteractorProtocol {
    weak var output: AddTaskInteractorOutput?
    
    func addInitialMessage() {
        let message = Message(text: "Привет! Я помогу тебе добавить задачи в твой список дел. Что ты хочешь добавить?", isUser: false)
        output?.didAddMessage(message)
    }
    
    func addRepeatMessage() {
        let message = Message(text: "Если хочешь добавить ещё что-нибудь, то опиши мне задачу.", isUser: false)
        output?.didAddMessage(message)
    }
    
    func addMessage(text: String, isUser: Bool) {
        let message = Message(text: text, isUser: isUser)
        output?.didAddMessage(message)
    }
}
