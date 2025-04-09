//
//  KeychainHelper.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 06.04.2025.
//

import Foundation
import Security

enum KeychainError: Error {
    case duplicate
    case notFound
    case unknown(OSStatus)
}

struct KeychainHelper {
    static func save(password: String, for account: String) throws {
        let data = password.data(using: .utf8)!
        let query: [CFString: Any] = [
            kSecClass:           kSecClassGenericPassword,
            kSecAttrAccount:     account,
            kSecValueData:       data,
            kSecAttrAccessible:  kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            throw KeychainError.duplicate
        default:
            throw KeychainError.unknown(status)
        }
    }

    static func loadPassword(for account: String) throws -> String? {
        let query: [CFString: Any] = [
            kSecClass:           kSecClassGenericPassword,
            kSecAttrAccount:     account,
            kSecReturnData:      kCFBooleanTrue as Any,
            kSecMatchLimit:      kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess,
              let data = item as? Data,
              let pwd  = String(data: data, encoding: .utf8)
        else {
            throw KeychainError.unknown(status)
        }
        return pwd
    }

    static func delete(account: String) throws {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
}
