//
//  ReminderSettings.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.04.2025.
//

import UIKit

@objcMembers
class ReminderSettings: UIView {
    
    // MARK: - Constants
    
    private struct Constants {
        static let fontName = "Nunito-Regular"
        static let fontSize: CGFloat = 17
        static let pencilIconName = "PencilIcon"
        static let reminderNotSetText = "Напоминание не задано"
        static let spacingBetweenLabelAndIcon: CGFloat = 5
    }
    
    // MARK: - UI Elements
    
    private let reminderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constants.fontName, size: Constants.fontSize)
        label.textColor = .black
        return label
    }()
    
    private let pencilIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: Constants.pencilIconName))
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    // MARK: - Properties
    
    /// Массив напоминаний (до двух)
    var reminders: [String?] = [nil, nil] {
        didSet {
            updateReminderLabel()
        }
    }
    
    /// Замыкание для обработки редактирования напоминаний
    var onEditReminders: (() -> Void)?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        addSubview(reminderLabel)
        addSubview(pencilIconView)
    }
    
    private func setupConstraints() {
        reminderLabel.translatesAutoresizingMaskIntoConstraints = false
        pencilIconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            reminderLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            reminderLabel.topAnchor.constraint(equalTo: topAnchor),
            reminderLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            pencilIconView.leadingAnchor.constraint(equalTo: reminderLabel.trailingAnchor, constant: Constants.spacingBetweenLabelAndIcon),
            pencilIconView.centerYAnchor.constraint(equalTo: reminderLabel.centerYAnchor),
            pencilIconView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleReminderTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func handleReminderTap() {
        onEditReminders?()
    }
    
    // MARK: - Private Methods
    
    private func updateReminderLabel() {
        let activeReminders = reminders.compactMap { $0 }
        if activeReminders.isEmpty {
            reminderLabel.text = Constants.reminderNotSetText
        } else {
            var uniqueReminders: [String] = []
            for reminder in activeReminders where !uniqueReminders.contains(reminder) {
                uniqueReminders.append(reminder)
            }
            let combined = uniqueReminders.joined(separator: " и ")
            reminderLabel.text = fixCapitalization(in: combined)
        }
    }
    
    private func fixCapitalization(in text: String) -> String {
        var words = text.components(separatedBy: .whitespaces)
        var foundCapitalWord = false
        
        for i in 0..<words.count {
            let word = words[i]
            if let first = word.first, first.isUppercase {
                if foundCapitalWord {
                    words[i] = word.lowercased()
                } else {
                    foundCapitalWord = true
                }
            }
        }
        return words.joined(separator: " ")
    }
}
