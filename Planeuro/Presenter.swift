//
//  Presenter.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

protocol LoginPresenterProtocol {
    func presentLoginSuccess()
    func presentLoginFailure(error: String)
}

final class LoginPresenter: LoginPresenterProtocol {
    weak var view: LoginViewController?

    func presentLoginSuccess() {
        // Обработка успешной авторизации
    }

    func presentLoginFailure(error: String) {
        // Обработка ошибки авторизации
    }
}
