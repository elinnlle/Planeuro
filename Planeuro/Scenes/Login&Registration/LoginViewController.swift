//
//  RegistrationViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.01.2025.
//

import UIKit

final class LoginViewController: UIViewController {
    private let interactor: LoginInteractorProtocol
    
    // MARK: - Константы
    
    private enum Constants {
        // Градиент
        static let gradientLocations: [NSNumber] = [0.0, 0.27, 0.73, 1.0]
        static let gradientStartPoint = CGPoint(x: 0.5, y: 1.0)
        static let gradientEndPoint = CGPoint(x: 0.5, y: 0.0)
        
        // Отступы и размеры
        static let stackViewHorizontalPadding: CGFloat = 20
        static let combinedRegisterButtonBottomPadding: CGFloat = 30
        static let stackViewSpacing: CGFloat = 16
        static let titleFontSize: CGFloat = 45
        static let descriptionFontSize: CGFloat = 26
        static let loginButtonFontSize: CGFloat = 20
        static let forgotPasswordButtonFontSize: CGFloat = 17
        static let combinedRegisterButtonHeight: CGFloat = 55
        static let combinedRegisterButtonWidth: CGFloat = 260
        static let loginButtonHeight: CGFloat = 50
        static let loginButtonWidth: CGFloat = 260
        static let buttonCornerRadius: CGFloat = 20.0
        
        // Тень
        static let shadowOpacity: Float = 0.25
        static let shadowRadius: CGFloat = 4
        static let shadowOffset = CGSize(width: 0, height: 4)
        
        // Интервал между строками
        static let lineSpacing: CGFloat = 8
        
        // Количество слов для переноса строки
        static let wordsPerLine: Int = 2
    }

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
        setupTapGesture()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
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
        gradientLayer.locations = Constants.gradientLocations
        gradientLayer.startPoint = Constants.gradientStartPoint
        gradientLayer.endPoint = Constants.gradientEndPoint
        gradientLayer.frame = view.bounds

        // Добавляем градиентный слой на view
        view.layer.insertSublayer(gradientLayer, at: 0)

        // Создаем UI
        let stackView = createStackView()
        view.addSubview(stackView)

        // Закрепляем stackView по центру с отступами
        stackView.pinCenter(to: view)
        stackView.pinLeft(to: view, Constants.stackViewHorizontalPadding)
        stackView.pinRight(to: view, Constants.stackViewHorizontalPadding)

        // Добавляем комбинированную кнопку
        let combinedRegisterButton = createCombinedRegisterButton()
        view.addSubview(combinedRegisterButton)
        combinedRegisterButton
            .pinBottom(to: view, Constants.combinedRegisterButtonBottomPadding)
        combinedRegisterButton
            .pinCenterX(to: view)
        
        // Убираем кнопку Back из навигации
        self.navigationItem.hidesBackButton = true

        // Обновляем layout, чтобы все элементы отобразились корректно
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true) // Скрывает клавиатуру
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
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }

    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "Planeuro"
        label.font = UIFont(name: "Nunito-Black", size: Constants.titleFontSize)
        label.textColor = .color800
        label.textAlignment = .center
        return label
    }

    private func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.text = formatDescriptionText("Для использования этого приложения необходим аккаунт")
        label.font = UIFont(name: "Nunito-ExtraBold", size: Constants.descriptionFontSize)
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
            if (index + 1) % Constants.wordsPerLine == 0 {
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
        button.titleLabel?.font = UIFont(name: "Nunito-ExtraBold", size: Constants.loginButtonFontSize)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.clipsToBounds = true // Обрезаем градиент по углам кнопки

        // Устанавливаем градиентный фон
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.color500.cgColor,
            UIColor.color600.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Начало сверху
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // Конец снизу
        gradientLayer.frame = CGRect(x: 0, y: 0, width: Constants.loginButtonWidth, height: Constants.loginButtonHeight)

        // Добавляем градиент в слой кнопки
        button.layer.insertSublayer(gradientLayer, at: 0)

        // Добавляем тень
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = Constants.shadowOpacity
        button.layer.shadowOffset = Constants.shadowOffset
        button.layer.shadowRadius = Constants.shadowRadius

        // Устанавливаем размеры кнопки
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setWidth(Constants.loginButtonWidth)
        button.setHeight(Constants.loginButtonHeight)
        
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)

        return button
    }

    private func createForgotPasswordButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Забыли пароль?", for: .normal)
        button.setTitleColor(.color500, for: .normal)
        button.titleLabel?.font = UIFont(name: "Nunito-Regular", size: Constants.forgotPasswordButtonFontSize)
        return button
    }

    private func createCombinedRegisterButton() -> UIButton {
        let button = UIButton()
        let fullText = "Ещё нет аккаунта?\nЗарегистрироваться"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Настройка стилей текста
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Constants.lineSpacing // Добавляем "воздух" между строками
        paragraphStyle.alignment = .center // Центрируем текст
        
        // Настройка стиля для всего текста
        let font = UIFont(
            name: "Nunito-Regular",
            size: Constants.forgotPasswordButtonFontSize
        ) ?? UIFont.systemFont(
            ofSize: Constants.forgotPasswordButtonFontSize
        )
        attributedString.addAttribute(
            .font,
            value: font,
            range: NSRange(location: 0, length: fullText.count)
        )
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: fullText.count)
        )
        attributedString.addAttribute(
            .foregroundColor,
            value: UIColor.color200,
            range: NSRange(location: 0, length: "Ещё нет аккаунта?".count)
        )
        
        // Настройка стиля для "Зарегистрироваться"
        if let range = fullText.range(of: "Зарегистрироваться") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.color100, range: nsRange)
            attributedString.addAttribute(.font,value: UIFont(name: "NunitoSans-Bold",size: Constants.forgotPasswordButtonFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.forgotPasswordButtonFontSize),range: nsRange
            )
        }
        
        // Устанавливаем атрибутированный текст для кнопки
        button.setAttributedTitle(attributedString, for: .normal)
        button.titleLabel?.numberOfLines = 2 // Указываем, что текст может быть на двух строках
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Устанавливаем размеры кнопки
        button.setWidth(Constants.combinedRegisterButtonWidth)
        button.setHeight(Constants.combinedRegisterButtonHeight)

        // Обработчик нажатия на кнопку
        button.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        
        return button
    }

    @objc private func didTapRegisterButton() {
        // Переход на экран RegistrationViewController
        let registrationPresenter = RegistrationPresenter()
        let registrationInteractor = RegistrationInteractor(presenter: registrationPresenter)
        let registrationViewController = RegistrationViewController(interactor: registrationInteractor)
        
        // Переход через навигацию
        navigationController?.pushViewController(registrationViewController, animated: true)
    }
    
    @objc private func didTapLoginButton() {
            // Переход на экран MainViewController
            let mainViewController = MainViewController()
            navigationController?.pushViewController(mainViewController, animated: true)
        }
}
