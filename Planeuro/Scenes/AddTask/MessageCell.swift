// MessageCell.swift
// Planeuro
//
// Created by Эльвира Матвеенко on 27.03.2025.
//

import UIKit

class MessageCell: UITableViewCell {
    private enum Constants {
        static let padding: CGFloat = 10
        static let maxWidth: CGFloat = 350
        static let cornerRadius: CGFloat = 20
        static let messageFontSize: CGFloat = 17
    }

    private let messageTextView = UITextView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var maxWidthConstraint: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(messageTextView)
        messageTextView.isEditable = false
        messageTextView.isScrollEnabled = false
        messageTextView.font = UIFont(name: "Nunito-Regular", size: Constants.messageFontSize)
        messageTextView.textColor = .black
        messageTextView.textContainerInset = UIEdgeInsets(
            top: Constants.padding,
            left: Constants.padding,
            bottom: Constants.padding,
            right: Constants.padding
        )
        messageTextView.layer.cornerRadius = Constants.cornerRadius
        messageTextView.clipsToBounds = true

        // constraints
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        leadingConstraint = messageTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding)
        trailingConstraint = messageTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding)
        maxWidthConstraint = messageTextView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.maxWidth)

        NSLayoutConstraint.activate([
            messageTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.padding),
            messageTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.padding),
            maxWidthConstraint
        ])

        // спиннер внутри bubble
        messageTextView.addSubview(activityIndicator)
        activityIndicator.color = .color300
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: messageTextView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: messageTextView.centerYAnchor)
        ])
    }

    func configure(with message: Message) {
        // сначала снимем все
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false

        if message.isLoading {
            // индикатор загрузки
            messageTextView.text = ""  // Текст скрыт
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()

            // стили под бот‑сообщение
            messageTextView.backgroundColor = .white
            messageTextView.textAlignment = .center
            messageTextView.layer.borderColor = UIColor.clear.cgColor
            leadingConstraint.isActive = true

        } else {
            // обычный текст
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true

            messageTextView.text = message.text
            messageTextView.layer.borderWidth = 0
            messageTextView.layer.borderColor = UIColor.clear.cgColor

            if message.isUser {
                // справа
                messageTextView.backgroundColor = .color300
                messageTextView.textAlignment = .right
                messageTextView.layer.maskedCorners = [
                    .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner
                ]
                trailingConstraint.isActive = true
            } else {
                // слева
                messageTextView.backgroundColor = .white
                messageTextView.layer.borderWidth = 1
                messageTextView.layer.borderColor = UIColor.color300.cgColor
                messageTextView.textAlignment = .left
                messageTextView.layer.maskedCorners = [
                    .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner
                ]
                leadingConstraint.isActive = true
            }
        }
    }
}
