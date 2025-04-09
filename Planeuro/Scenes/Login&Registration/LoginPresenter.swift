//
//  LoginPresenter.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

import UIKit

// Протокол для обработки результатов входа
protocol LoginPresenterProtocol {
    func presentLoginSuccess()
    func presentLoginFailure(error: String)
}

final class LoginPresenter: LoginPresenterProtocol {
    weak var view: LoginViewController?

    func presentLoginSuccess() {
        DispatchQueue.main.async {
            self.view?.navigateToMain()
        }
    }

    func presentLoginFailure(error: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Ошибка входа",
                message: error,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.view?.present(alert, animated: true)
        }
    }
}
