//
//  RegistrationViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

import UIKit

final class LoginViewController: UIViewController {
    private let interactor: LoginInteractorProtocol

    init(interactor: LoginInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Настройка интерфейса

    private func setupUI() {
        // Устанавливаем градиентный фон для всего экрана
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.color600.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.color600.cgColor
        ]
        gradientLayer.locations = [0.0, 0.27, 0.73, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0) // Начало снизу
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)   // Конец сверху
        gradientLayer.frame = view.bounds

        // Добавляем градиентный слой на view
        view.layer.insertSublayer(gradientLayer, at: 0)

        // Создаем UI
        let stackView = createStackView()
        view.addSubview(stackView)

        // Закрепляем stackView по центру с отступами
        stackView.pinCenter(to: view)
        stackView.pinLeft(to: view, 20)
        stackView.pinRight(to: view, 20)

        // Добавляем комбинированную кнопку
        let combinedRegisterButton = createCombinedRegisterButton()
        view.addSubview(combinedRegisterButton)
        combinedRegisterButton.pinBottom(to: view, 30)
        combinedRegisterButton.pinCenterX(to: view)

        // Обновляем layout, чтобы все элементы отобразились корректно
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    // MARK: - Создание UI элементов

    private func createStackView() -> UIStackView {
        let titleLabel = createTitleLabel()
        let descriptionLabel = createDescriptionLabel()
        let emailField = createInputField(placeholder: "Введите e-mail")
        let passwordField = createInputField(placeholder: "Введите пароль", isSecure: true)
        let forgotPasswordButton = createForgotPasswordButton()
        let loginButton = createLoginButton()

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, descriptionLabel, emailField, passwordField,
            loginButton, forgotPasswordButton
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }

    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "Planeuro"
        label.font = UIFont(name: "Nunito-Black", size: 45)
        label.textColor = .color800
        label.textAlignment = .center
        return label
    }

    private func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.text = formatDescriptionText("Для использования этого приложения необходим аккаунт")
        label.font = UIFont(name: "Nunito-ExtraBold", size: 26)
        label.textColor = .color800
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private func formatDescriptionText(_ text: String) -> String {
        let words = text.split(separator: " ")
        var formattedText = ""
        
        for (index, word) in words.enumerated() {
            formattedText += word + " "
            
            // Добавляем перенос строки после каждых 2 слов
            if (index + 1) % 2 == 0 {
                formattedText += "\n"
            }
        }
        
        return formattedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func createInputField(placeholder: String, isSecure: Bool = false) -> InputField {
        return InputField(placeholder: placeholder, isSecure: isSecure)
    }

    private func createLoginButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = UIFont(name: "Nunito-ExtraBold", size: 20)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true // Обрезаем градиент по углам кнопки

        // Устанавливаем градиентный фон
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.color500.cgColor,
            UIColor.color600.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Начало сверху
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Конец снизу
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 260, height: 50)

        // Добавляем градиент в слой кнопки
        button.layer.insertSublayer(gradientLayer, at: 0)

        // Добавляем тень
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 4

        // Устанавливаем размеры кнопки
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setWidth(260)
        button.setHeight(50)

        return button
    }

    private func createForgotPasswordButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Забыли пароль?", for: .normal)
        button.setTitleColor(.color500, for: .normal)
        button.titleLabel?.font = UIFont(name: "NunitoSans-Regular", size: 17)
        return button
    }

    private func createCombinedRegisterButton() -> UIButton {
        let button = UIButton()
        let fullText = "Ещё нет аккаунта?\nЗарегистрироваться"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Настройка стилей текста
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8 // Добавляем "воздух" между строками
        paragraphStyle.alignment = .center // Центрируем текст
        
        // Настройка стиля для всего текста
        let font = UIFont(name: "NunitoSans-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
        attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: fullText.count))
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: fullText.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.color200, range: NSRange(location: 0, length: "Ещё нет аккаунта?".count))
        
        // Настройка стиля для "Зарегистрироваться"
        if let range = fullText.range(of: "Зарегистрироваться") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.color100, range: nsRange)
            attributedString.addAttribute(.font, value: UIFont(name: "NunitoSans-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17), range: nsRange)
        }
        
        // Устанавливаем атрибутированный текст для кнопки
        button.setAttributedTitle(attributedString, for: .normal)
        button.titleLabel?.numberOfLines = 2 // Указываем, что текст может быть на двух строках
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Устанавливаем размеры кнопки
        button.setWidth(260)
        button.setHeight(55)
        
        return button
    }
}
