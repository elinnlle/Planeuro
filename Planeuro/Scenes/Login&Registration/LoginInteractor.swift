//
//  LoginInteractor.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

import Foundation

protocol LoginInteractorProtocol {
    func handleLogin(email: String, password: String)
}

final class LoginInteractor: LoginInteractorProtocol {
    private let presenter: LoginPresenterProtocol

    init(presenter: LoginPresenterProtocol) {
        self.presenter = presenter
    }

    func handleLogin(email: String, password: String) {
        do {
            guard let stored = try KeychainHelper.loadPassword(for: email) else {
                presenter.presentLoginFailure(error: "Пользователь не найден")
                return
            }
            guard stored == password else {
                presenter.presentLoginFailure(error: "Неверный пароль")
                return
            }
            // Отмечаем «залогинился»
            AuthManager.shared.setUserLoggedIn(true)
            presenter.presentLoginSuccess()
        } catch {
            presenter.presentLoginFailure(error: "Keychain error: \(error)")
        }
    }
}
