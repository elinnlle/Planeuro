//
//  AddTaskPresenter.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.03.2025.
//

import Foundation

protocol AddTaskPresenterProtocol {
    func viewDidLoad()
    func didTapSendButton(with text: String)
    func didTapYesButton()
    func didTapNoButton()
}

class AddTaskPresenter: AddTaskPresenterProtocol {
    weak var view: AddTaskView?
    var interactor: AddTaskInteractorProtocol
    
    init(view: AddTaskView, interactor: AddTaskInteractorProtocol) {
        self.view = view
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        interactor.addInitialMessage()
    }
    
    func didTapSendButton(with text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Игнорируем placeholder или пустой ввод
        if trimmedText.isEmpty || trimmedText == "Введите сообщение..." { return }
        interactor.addMessage(text: trimmedText, isUser: true)
    }
    
    func didTapYesButton() {
        interactor.addMessage(text: "Да", isUser: true)
    }
    
    func didTapNoButton() {
        interactor.addMessage(text: "Нет", isUser: true)
    }
}

// MARK: - Получение результата от Interactor
extension AddTaskPresenter: AddTaskInteractorOutput {
    func didAddMessage(_ message: Message) {
        view?.displayNewMessage(message)
    }
}
