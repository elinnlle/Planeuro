//
//  Interactor.swift
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

// Протокол для обработки регистрации
protocol RegistrationInteractorProtocol {
    func handleRegistration(name: String, email: String, password: String, confirmPassword: String)
}

final class RegistrationInteractor: RegistrationInteractorProtocol {
    private let presenter: RegistrationPresenterProtocol

    init(presenter: RegistrationPresenterProtocol) {
        self.presenter = presenter
    }

    func handleRegistration(name: String, email: String, password: String, confirmPassword: String) {
        // Проверяем, совпадают ли пароли
        if password != confirmPassword {
            presenter.presentRegistrationFailure(error: "Пароли не совпадают")
            return
        }
        
        // Проверяем валидность email
        if !isValidEmail(email) {
            presenter.presentRegistrationFailure(error: "Неверный формат e-mail")
            return
        }
        
        // Проверяем, что пароль достаточно длинный
        if password.count < 6 {
            presenter.presentRegistrationFailure(error: "Пароль должен быть не менее 6 символов")
            return
        }

        // Успешная регистрация
        
        // После успешной регистрации вызываем презентер с успешным результатом
        presenter.presentRegistrationSuccess()
    }

    // Функция для проверки валидности email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}

