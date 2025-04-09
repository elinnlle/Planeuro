//
//  MailService.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 05.04.2025.
//

import Foundation
import SwiftSMTP

final class MailService {
    static let shared = MailService()
    private init() {}

    /// Шлёт код подтверждения на `userEmail`
    func sendVerification(to userEmail: String, code: String) async throws {
        let from = Mail.User(name: "Planeuro",
                             email: "planeuro@internet.ru")
        let to   = Mail.User(name: nil,
                             email: userEmail)

        let mail = Mail(
            from: from,
            to: [to],
            subject: "Подтверждение регистрации",
            text: """
                  Вы зарегистрировались в Planeuro.
                  Ваш код подтверждения: \(code)
                  """
        )
        try await SMTPConfig.transport.send(mail)
    }

    /// Шлёт временный пароль для сброса
    func sendResetLink(to userEmail: String, tmpPassword: String) async throws {
        let from = Mail.User(name: "Planeuro",
                             email: "planeuro@internet.ru")
        let to   = Mail.User(name: nil,
                             email: userEmail)

        let mail = Mail(
            from: from,
            to: [to],
            subject: "Сброс пароля в Planeuro",
            text: """
                  Вы запросили сброс пароля.
                  Ваш временный пароль: \(tmpPassword)
                  Пожалуйста, поменяйте его при следующем входе.
                  """
        )
        try await SMTPConfig.transport.send(mail)
    }
}

extension MailService {
    /// Шлёт e-mail-напоминание о задаче
    func sendTaskReminder(to userEmail: String, task: Tasks) async throws {
        let from = Mail.User(name: "Planeuro", email: "planeuro@internet.ru")
        let to   = Mail.User(name: nil, email: userEmail)

        let subject = "Напоминание: \(task.title)"
        // Формируем тело письма
        let timeStr = task.startDate.formatted(date: .long, time: .shortened)
        let body = """
                   Здравствуйте!
                   Ваше событие «\(task.title)» назначено на \(timeStr).
                   Не забудьте подготовиться.
                   """

        let mail = Mail(from: from, to: [to], subject: subject, text: body)
        try await SMTPConfig.transport.send(mail)
    }
}
