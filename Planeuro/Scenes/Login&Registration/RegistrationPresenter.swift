//
//  RegistrationPresenter.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

import UIKit

// Протокол для обработки результатов регистрации
protocol RegistrationPresenterProtocol {
    func presentRegistrationSuccess()
    func presentRegistrationFailure(error: String)
}

final class RegistrationPresenter: RegistrationPresenterProtocol {
    weak var view: RegistrationViewController?

    func presentRegistrationSuccess() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Успех",
                message: "Регистрация прошла успешно!",
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(title: "OK", style: .default) { _ in
                    self.view?.navigationController?.popViewController(animated: true)
                }
            )
            self.view?.present(alert, animated: true)
        }
    }

    func presentRegistrationFailure(error: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Ошибка",
                message: error,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.view?.present(alert, animated: true)
        }
    }
}

