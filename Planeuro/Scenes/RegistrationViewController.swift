//
//  RegistrationViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 18.01.2025.
//

import UIKit

final class RegistrationViewController: UIViewController {
    private let interactor: RegistrationInteractorProtocol

    // MARK: - Константы
    
    private enum Constants {
        // Градиент
        static let gradientLayerLocations: [NSNumber] = [0.0, 0.27, 0.73, 1.0]
        static let gradientLayerStartPoint = CGPoint(x: 0.5, y: 1.0)
        static let gradientLayerEndPoint = CGPoint(x: 0.5, y: 0.0)
        
        // Отступы и размеры
        static let stackViewHorizontalPadding: CGFloat = 20.0
        static let combinedRegisterButtonBottomPadding: CGFloat = 30.0
        static let stackViewSpacing: CGFloat = 16.0
        static let titleLabelFontSize: CGFloat = 45.0
        static let registerButtonFontSize: CGFloat = 20.0
        static let combinedButtonFontSize: CGFloat = 17.0
        static let combinedButtonHeight: CGFloat = 55.0
        static let registerButtonWidth: CGFloat = 260.0
        static let registerButtonHeight: CGFloat = 50.0
        static let buttonCornerRadius: CGFloat = 20.0
        
        // Тень
        static let shadowOpacity: Float = 0.25
        static let shadowRadius: CGFloat = 4.0
        static let shadowOffsetHeight: CGFloat = 4.0
        
        // Межстрочный интервал для текста в комбинированной кнопке
        static let lineSpacing: CGFloat = 8.0
    }

    // MARK: - Инициализация

    init(interactor: RegistrationInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Жизненный цикл

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTapGesture()
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
        gradientLayer.locations = Constants.gradientLayerLocations
        gradientLayer.startPoint = Constants.gradientLayerStartPoint
        gradientLayer.endPoint = Constants.gradientLayerEndPoint
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
        combinedRegisterButton.pinBottom(to: view, Constants.combinedRegisterButtonBottomPadding)
        combinedRegisterButton.pinCenterX(to: view)
        
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
        let nameField = createInputField(placeholder: "Введите имя")
        let emailField = createInputField(placeholder: "Введите e-mail")
        let passwordField = createInputField(placeholder: "Введите пароль", isSecure: true)
        let confirmPasswordField = createInputField(placeholder: "Повторите пароль", isSecure: true)
        let registerButton = createRegisterButton()

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, nameField, emailField, passwordField, confirmPasswordField,
            registerButton
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }

    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "Planeuro"
        label.font = UIFont(name: "Nunito-Black", size: Constants.titleLabelFontSize)
        label.textColor = .color800
        label.textAlignment = .center
        return label
    }

    private func createInputField(placeholder: String, isSecure: Bool = false) -> InputField {
        return InputField(placeholder: placeholder, isSecure: isSecure)
    }

    private func createRegisterButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Зарегистрироваться", for: .normal)
        button.titleLabel?.font = UIFont(name: "Nunito-ExtraBold", size: Constants.registerButtonFontSize)
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
        gradientLayer.frame = CGRect(x: 0, y: 0, width: Constants.registerButtonWidth, height: Constants.registerButtonHeight)

        // Добавляем градиент в слой кнопки
        button.layer.insertSublayer(gradientLayer, at: 0)

        // Добавляем тень
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = Constants.shadowOpacity
        button.layer.shadowOffset = CGSize(width: 0, height: Constants.shadowOffsetHeight)
        button.layer.shadowRadius = Constants.shadowRadius

        // Устанавливаем размеры кнопки
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setWidth(Constants.registerButtonWidth)
        button.setHeight(Constants.registerButtonHeight)

        return button
    }

    private func createCombinedRegisterButton() -> UIButton {
        let button = UIButton()
        let fullText = "Уже есть аккаунт?\nВойти"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Настройка стилей текста
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Constants.lineSpacing // Добавляем "воздух" между строками
        paragraphStyle.alignment = .center // Центрируем текст
        
        // Настройка стиля для всего текста
        let font = UIFont(
            name: "Nunito-Regular",
            size: Constants.combinedButtonFontSize
        ) ?? UIFont.systemFont(
            ofSize: Constants.combinedButtonFontSize
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
            range: NSRange(location: 0,length: "Уже есть аккаунт?".count)
        )
        
        // Настройка стиля для "Войти"
        if let range = fullText.range(of: "Войти") {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: UIColor.color100, range: nsRange)
            attributedString.addAttribute(.font, value: UIFont(name: "NunitoSans-Bold", size: Constants.combinedButtonFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.combinedButtonFontSize), range: nsRange)
        }
        
        // Устанавливаем атрибутированный текст для кнопки
        button.setAttributedTitle(attributedString, for: .normal)
        button.titleLabel?.numberOfLines = 2 // Указываем, что текст может быть на двух строках
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Устанавливаем размеры кнопки
        button.setWidth(Constants.registerButtonWidth)
        button.setHeight(Constants.combinedButtonHeight)
        
        // Обработчик нажатия на кнопку
        button.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
            
        return button
    }

    // MARK: - Действия

    @objc private func didTapRegisterButton() {
        // Возврат на предыдущий экран
        navigationController?.popViewController(animated: true)
    }
}
