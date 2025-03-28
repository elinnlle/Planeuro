//
//  AddTaskInteractor.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.03.2025.
//

import Foundation

protocol AddTaskInteractorProtocol {
    func addInitialMessage()
    func addMessage(text: String, isUser: Bool)
}

// Протокол для передачи данных обратно в Presenter
protocol AddTaskInteractorOutput: AnyObject {
    func didAddMessage(_ message: Message)
}

class AddTaskInteractor: AddTaskInteractorProtocol {
    weak var output: AddTaskInteractorOutput?
    
    func addInitialMessage() {
        let message = Message(text: "Привет! Я помогу тебе добавить дедлайны в твой список. Какое задание ты хочешь добавить?", isUser: false)
        output?.didAddMessage(message)
    }
    
    func addMessage(text: String, isUser: Bool) {
        let message = Message(text: text, isUser: isUser)
        output?.didAddMessage(message)
    }
}
