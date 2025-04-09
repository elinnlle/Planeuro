// Message.swift
// Planeuro
//
// Created by Эльвира Матвеенко on 17.03.2025.
//

import UIKit

struct Message {
    let text: String?      // текст (nil, если это индикатор загрузки)
    let isUser: Bool       // чьё сообщение
    let isLoading: Bool    // true → показываем спиннер

    // обычное сообщение
    init(text: String, isUser: Bool) {
        self.text = text
        self.isUser = isUser
        self.isLoading = false
    }

    // индикатор загрузки
    init(loading isLoading: Bool, isUser: Bool = false) {
        self.text = nil
        self.isUser = isUser
        self.isLoading = isLoading
    }
}
