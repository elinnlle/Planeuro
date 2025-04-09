//
//  SMTPConfig.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 05.04.2025.
//

import SwiftSMTP

enum SMTPConfig {
    static let transport = SMTP(
        hostname: "smtp.mail.ru",
        email: "planeuro@internet.ru",
        password: "security",
        port: 465,
        tlsMode: .requireTLS
    )
}
