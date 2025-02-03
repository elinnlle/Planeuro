//
//  InputField.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

import UIKit

final class InputField: UIView {
    
    // MARK: - Свойства
    
    private let textField = UITextField()
    private let placeholder: String
    private let isSecure: Bool
    private var showPasswordButton: UIButton?

    // MARK: - Константы
    
    private enum Constants {
        static let leftPadding: CGFloat = 15
        static let rightPadding: CGFloat = 15
        static let buttonSize: CGFloat = 40
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 20
        static let inputFieldWidth: CGFloat = 260
        static let inputFieldHeight: CGFloat = 50
        static let fontSize: CGFloat = 17
        static let placeholderHeight: CGFloat = 20
    }

    // MARK: - Инициализаторы
    
    init(placeholder: String, isSecure: Bool = false) {
        self.placeholder = placeholder
        self.isSecure = isSecure
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Настройка UI
    
    private func setupUI() {
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.font = UIFont(name: "Nunito-Regular", size: Constants.fontSize)

        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false

        // Устанавливаем отступы для текстового поля слева
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.leftPadding, height: Constants.placeholderHeight))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // Устанавливаем отступы для текстового поля справа
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.rightPadding, height: Constants.placeholderHeight))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always

        if isSecure {
            addShowPasswordButton()
        }

        self.layer.borderWidth = Constants.borderWidth
        self.layer.borderColor = UIColor.color500.cgColor
        self.layer.cornerRadius = Constants.cornerRadius

        // Размеры поля ввода
        self.setWidth(mode: .equal, Constants.inputFieldWidth)
        self.setHeight(mode: .equal, Constants.inputFieldHeight)

        // Закрепляем textField
        textField.pinLeft(to: self)
        textField.pinRight(to: self)
        textField.pinTop(to: self)
        textField.pinBottom(to: self)
    }

    // MARK: - Видимость пароля
    
    private func addShowPasswordButton() {
        showPasswordButton = UIButton(type: .custom)
        showPasswordButton?.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        showPasswordButton?.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
        showPasswordButton?.tintColor = UIColor.gray

        showPasswordButton?.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        let buttonContainer = UIView(frame: CGRect(x: 0, y: 0, width: Constants.buttonSize, height: Constants.buttonSize))
        buttonContainer.addSubview(showPasswordButton!)
        showPasswordButton?.frame = CGRect(x: 0, y: 0, width: Constants.buttonSize, height: Constants.buttonSize)

        textField.rightView = buttonContainer
        textField.rightViewMode = .always
    }

    // MARK: - Действия
    
    @objc private func togglePasswordVisibility() {
        textField.isSecureTextEntry.toggle()
        showPasswordButton?.isSelected.toggle()
    }
}
