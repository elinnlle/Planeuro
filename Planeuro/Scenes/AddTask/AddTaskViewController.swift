//
//  AddTaskViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 16.03.2025.
//

import UIKit

// Протокол, через который Presenter будет обновлять View
protocol AddTaskView: AnyObject {
    func displayNewMessage(_ message: Message)
}

class AddTaskViewController: UIViewController {
    
    // MARK: - Свойства
    
    private let messagesTableView = UITableView()
    private let inputTextView = UITextView()
    private let sendButton = UIButton(type: .system)
    private let yesButton = UIButton(type: .system)
    private let noButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    // Ограничения для прикрепления inputTextView к низу и его высоты
    private var keyboardHeightConstraint: NSLayoutConstraint?
    private var inputTextViewHeightConstraint: NSLayoutConstraint?
    private var messages: [Message] = []
    var presenter: AddTaskPresenterProtocol!
    
    // MARK: - Константы
    
    private enum Constants {
        static let initialInputTextViewHeight: CGFloat = 80
        static let inputTextViewEditingHeight: CGFloat = 50
        static let titleFontSize: CGFloat = 27
        static let buttonFontSize: CGFloat = 17
        static let backgroundViewHeight: CGFloat = 125
        static let backgroundViewTopPadding: CGFloat = 65
        static let titleLabelBottomPadding: CGFloat = 7
        static let buttonBottomPadding: CGFloat = 10
        static let buttonLeftPadding: CGFloat = 10
        static let stackViewBottomPadding: CGFloat = 16
        static let stackViewWidth: CGFloat = 148
        static let stackViewHeight: CGFloat = 40
        static let buttonCornerRadius: CGFloat = 20
        static let messageTextViewTextContainerInsetTop: CGFloat = 10
        static let messageTextViewTextContainerInsetLeft: CGFloat = 10
        static let messageTextViewTextContainerInsetBottom: CGFloat = 10
        static let messageTextViewTextContainerInsetRight: CGFloat = 10
        static let tableViewContentInsetTop: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let estimatedRowHeight: CGFloat = 44
        static let stackViewSpacing: CGFloat = 10
        static let sendButtonRightPadding: CGFloat = 10
        static let sendButtonTopPadding: CGFloat = 10
        static let defaultBottomPadding: CGFloat = 0
        static let animationDuration: TimeInterval = 0.3
    }
    
    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        registerForKeyboardNotifications()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        // Связываем Interactor и Presenter
        let interactor = AddTaskInteractor()
        let presenter = AddTaskPresenter(view: self, interactor: interactor)
        interactor.output = presenter
        self.presenter = presenter
        
        presenter.viewDidLoad()
    }
    
    // Сразу показываем клавиатуру при появлении экрана
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputTextView.becomeFirstResponder()
    }
    
    deinit {
        unregisterForKeyboardNotifications()
    }
    
    // MARK: - Настройка UI
    
    private func setupUI() {
        // Подложка вверху экрана
        let backgroundView = UIView()
        backgroundView.backgroundColor = .color50
        backgroundView.layer.borderColor = UIColor.color300.cgColor
        backgroundView.layer.borderWidth = 1
        view.addSubview(backgroundView)
        backgroundView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, -Constants.backgroundViewTopPadding)
        backgroundView.pinLeft(to: view)
        backgroundView.pinRight(to: view)
        backgroundView.setHeight(Constants.backgroundViewHeight)
                
        // Заголовок
        let titleLabel = UILabel()
        titleLabel.text = "Твой помощник"
        titleLabel.font = UIFont(name: "Nunito-ExtraBold", size: Constants.titleFontSize)
        titleLabel.textColor = .color800
        backgroundView.addSubview(titleLabel)
        titleLabel.pinBottom(to: backgroundView.bottomAnchor, Constants.titleLabelBottomPadding)
        titleLabel.pinCenterX(to: backgroundView)
        
        // Кнопка "Назад"
        backButton.setImage(UIImage(named: "LeftIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.pinLeft(to: backgroundView, Constants.buttonLeftPadding)
        backButton.pinBottom(to: backgroundView, Constants.buttonBottomPadding)
        
        // Настройка таблицы сообщений
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        messagesTableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        messagesTableView.separatorStyle = .none
        messagesTableView.backgroundColor = .white
        messagesTableView.rowHeight = UITableView.automaticDimension
        messagesTableView.estimatedRowHeight = Constants.estimatedRowHeight
        messagesTableView.contentInset = UIEdgeInsets(top: Constants.tableViewContentInsetTop, left: 0, bottom: 0, right: 0)
        view.addSubview(messagesTableView)
        
        // Настройка поля ввода сообщений
        inputTextView.layer.borderWidth = Constants.borderWidth
        inputTextView.backgroundColor = .color50
        inputTextView.layer.borderColor = UIColor.color300.cgColor
        inputTextView.font = UIFont(name: "Nunito-Regular", size: Constants.buttonFontSize)
        inputTextView.textContainerInset = UIEdgeInsets(
            top: Constants.messageTextViewTextContainerInsetTop,
            left: Constants.messageTextViewTextContainerInsetLeft,
            bottom: Constants.messageTextViewTextContainerInsetBottom,
            right: Constants.messageTextViewTextContainerInsetRight
        )
        inputTextView.text = "Введите сообщение..."
        inputTextView.textColor = UIColor.color300
        inputTextView.tintColor = UIColor.color300
        inputTextView.delegate = self
        view.addSubview(inputTextView)
        inputTextViewHeightConstraint = inputTextView.setHeight(Constants.initialInputTextViewHeight) // Высота при скрытой клавиатуре 80
        
        // Настройка кнопки отправки
        sendButton.setImage(UIImage(named: "SendIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        view.addSubview(sendButton)
        
        // Настройка кнопок "Да" и "Нет"
        yesButton.setTitle("Да", for: .normal)
        yesButton.backgroundColor = .color300
        yesButton.titleLabel?.font = UIFont(name: "Nunito-Regular", size: Constants.buttonFontSize)
        yesButton.setTitleColor(.black, for: .normal)
        yesButton.layer.cornerRadius = Constants.buttonCornerRadius
        yesButton.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
        view.addSubview(yesButton)
        
        noButton.setTitle("Нет", for: .normal)
        noButton.backgroundColor = .color300
        noButton.titleLabel?.font = UIFont(name: "Nunito-Regular", size: Constants.buttonFontSize)
        noButton.setTitleColor(.black, for: .normal)
        noButton.layer.cornerRadius = Constants.buttonCornerRadius
        noButton.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
        view.addSubview(noButton)
        
        // Стек для кнопок "Да" и "Нет"
        let stackView = UIStackView(arrangedSubviews: [yesButton, noButton])
        stackView.axis = .horizontal
        stackView.spacing = Constants.stackViewSpacing
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        view.addSubview(stackView)
        stackView.pinCenterX(to: view)
        stackView.pinBottom(to: inputTextView.topAnchor, Constants.stackViewBottomPadding)
        stackView.setHeight(Constants.stackViewHeight)
        stackView.setWidth(Constants.stackViewWidth)
        yesButton.setHeight(Constants.stackViewHeight)
        noButton.setHeight(Constants.stackViewHeight)
        
        // Ограничения для таблицы сообщений
        messagesTableView.pinTop(to: backgroundView.bottomAnchor)
        messagesTableView.pinLeft(to: view)
        messagesTableView.pinRight(to: view)
        messagesTableView.pinBottom(to: stackView.topAnchor)
        
        // Ограничения для поля ввода сообщений (кроме высоты)
        inputTextView.pinLeft(to: view)
        inputTextView.pinRight(to: view)
        
        // Прикрепляем поле ввода к нижней части экрана
        keyboardHeightConstraint = inputTextView.pinBottom(to: view, 0)
        sendButton.pinRight(to: inputTextView.trailingAnchor, Constants.sendButtonRightPadding)
        sendButton.pinTop(to: inputTextView.topAnchor, Constants.sendButtonTopPadding)
    }
    
    // MARK: - Действия
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func sendButtonTapped() {
        presenter.didTapSendButton(with: inputTextView.text)
        inputTextView.text = ""
        inputTextView.becomeFirstResponder()
    }
    
    @objc private func yesButtonTapped() {
        presenter.didTapYesButton()
    }
    
    @objc private func noButtonTapped() {
        presenter.didTapNoButton()
    }
    
    @objc private func handleTapOutside(_ sender: UITapGestureRecognizer) {
        if inputTextView.isFirstResponder {
            inputTextView.resignFirstResponder()
            inputTextViewHeightConstraint?.constant = Constants.initialInputTextViewHeight
            UIView.animate(withDuration: Constants.animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Регистрация уведомлений о клавиатуре
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrameValue.cgRectValue.height
            updateInputTextViewConstraints(with: keyboardHeight)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        updateInputTextViewConstraints(with: Constants.defaultBottomPadding)
    }
    
    private func updateInputTextViewConstraints(with keyboardHeight: CGFloat) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.keyboardHeightConstraint?.constant = -keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - AddTaskView Protocol
extension AddTaskViewController: AddTaskView {
    func displayNewMessage(_ message: Message) {
        messages.append(message)
        messagesTableView.beginUpdates()
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        messagesTableView.insertRows(at: [indexPath], with: .automatic)
        messagesTableView.endUpdates()
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension AddTaskViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell",
                                                        for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITextViewDelegate
extension AddTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Введите сообщение..." {
            textView.text = ""
            textView.textColor = .black
        }
        inputTextViewHeightConstraint?.constant = Constants.inputTextViewEditingHeight
        UIView.animate(withDuration: Constants.animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Введите сообщение..."
            textView.textColor = UIColor.color300
        }
        inputTextViewHeightConstraint?.constant = Constants.initialInputTextViewHeight
        UIView.animate(withDuration: Constants.animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AddTaskViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton { return false }
        if touch.view is UIStackView { return false }
        return true
    }
}
