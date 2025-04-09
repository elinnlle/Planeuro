// File: AuthManager.swift
// Planeuro
// Created by Матвеенко Эльвира on 20.01.2025.

import Foundation

class AuthManager {
    static let shared = AuthManager()
    private init() {}

    func isUserLoggedIn() -> Bool {
        (try? KeychainHelper.loadPassword(for: "__session__")) != nil
    }

    func setUserLoggedIn(_ loggedIn: Bool) {
        if loggedIn {
            try? KeychainHelper.save(password: "1", for: "__session__")
        } else {
            try? KeychainHelper.delete(account: "__session__")
        }
    }

    // Полное удаление аккаунта
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        setUserLoggedIn(false)
        completion(true)
    }
}
