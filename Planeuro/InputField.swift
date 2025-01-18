//
//  InputField.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

import UIKit

final class InputField: UIView {
    private let textField = UITextField()
    private let placeholder: String
    private let isSecure: Bool

    init(placeholder: String, isSecure: Bool = false) {
        self.placeholder = placeholder
        self.isSecure = isSecure
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.font = UIFont(name: "NunitoSans-Regular", size: 17)

        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        // Устанавливаем отступы для текстового поля
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 20))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always

        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.color500.cgColor
        self.layer.cornerRadius = 20

        // Размеры поля ввода
        self.setWidth(mode: .equal, 260)
        self.setHeight(mode: .equal, 50)

        // Закрепляем textField
        textField.pinLeft(to: self)
        textField.pinRight(to: self)
        textField.pinTop(to: self)
        textField.pinBottom(to: self)
    }
}
