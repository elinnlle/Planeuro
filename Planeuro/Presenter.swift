//
//  Presenter.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

// Протокол для обработки результатов входа
protocol LoginPresenterProtocol {
    func presentLoginSuccess()
    func presentLoginFailure(error: String)
}

// Протокол для обработки результатов регистрации
protocol RegistrationPresenterProtocol {
    func presentRegistrationSuccess()
    func presentRegistrationFailure(error: String)
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

final class RegistrationPresenter: RegistrationPresenterProtocol {
    weak var view: RegistrationViewController?

    func presentRegistrationSuccess() {
        // Обработка успешной регистрации
    }

    func presentRegistrationFailure(error: String) {
        // Обработка ошибки регистрации
    }
}
