//
//  RegistrationInteractor.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

// RegistrationInteractor.swift
import Foundation

protocol RegistrationInteractorProtocol {
    func handleRegistration(name: String,
                            email: String,
                            password: String,
                            confirmPassword: String)
}

final class RegistrationInteractor: RegistrationInteractorProtocol {
    private let presenter: RegistrationPresenterProtocol

    init(presenter: RegistrationPresenterProtocol) {
        self.presenter = presenter
    }

    func handleRegistration(name: String,
                            email: String,
                            password: String,
                            confirmPassword: String)
    {
        // 1. Валидация
        guard password == confirmPassword else {
            presenter.presentRegistrationFailure(error: "Пароли не совпадают")
            return
        }
        guard isValidEmail(email) else {
            presenter.presentRegistrationFailure(error: "Неверный формат e-mail")
            return
        }
        guard password.count >= 6 else {
            presenter.presentRegistrationFailure(error: "Пароль ≥ 6 символов")
            return
        }

        // 2. Сохраняем пароль в Keychain
        do {
            try KeychainHelper.save(password: password, for: email)
        } catch KeychainError.duplicate {
            presenter.presentRegistrationFailure(error: "Пользователь уже существует")
            return
        } catch {
            presenter.presentRegistrationFailure(error: "Keychain error: \(error)")
            return
        }

        // 3. Сохраняем профиль и сразу сообщаем об успехе
        let defaults = UserDefaults.standard
        defaults.set(name, forKey: "userName")
        defaults.set(email, forKey: "userEmail")
        presenter.presentRegistrationSuccess()
        
        // 4. Асинхронно слать письмо (не блокируем UI)
        Task {
            let code = String(format: "%06d", Int.random(in: 0...999_999))
            do {
                try await MailService.shared.sendVerification(to: email, code: code)
            } catch {
                print("Mail send error: \(error)")
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
}

