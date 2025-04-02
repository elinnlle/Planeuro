//
//  LoginInteractor.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

import UIKit

// Протокол для обработки входа
protocol LoginInteractorProtocol {
    func handleLogin(email: String, password: String)
}

final class LoginInteractor: LoginInteractorProtocol {
    private let presenter: LoginPresenterProtocol

    init(presenter: LoginPresenterProtocol) {
        self.presenter = presenter
    }

    func handleLogin(email: String, password: String) {
        // Логика авторизации
    }
}
