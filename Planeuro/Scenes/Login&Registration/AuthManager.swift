//
//  AuthManager.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import Foundation

class AuthManager {
    static let shared = AuthManager()

    private init() {}

    // Проверяет, авторизован ли пользователь
    func isUserLoggedIn() -> Bool {
        // Для простоты пока используем UserDefaults.
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }

    // Сохраняет статус входа пользователя
    func setUserLoggedIn(_ loggedIn: Bool) {
        UserDefaults.standard.set(loggedIn, forKey: "isLoggedIn")
    }
}
