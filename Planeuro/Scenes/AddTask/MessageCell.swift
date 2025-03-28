//
//  MessageCell.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 27.03.2025.
//

import UIKit

class MessageCell: UITableViewCell {
    // MARK: - Константы
    private enum Constants {
        static let messageTextViewTextContainerInsetTop: CGFloat = 10
        static let messageTextViewTextContainerInsetLeft: CGFloat = 10
        static let messageTextViewTextContainerInsetBottom: CGFloat = 10
        static let messageTextViewTextContainerInsetRight: CGFloat = 10
        static let messageTextViewTopPadding: CGFloat = 6
        static let messageTextViewBottomPadding: CGFloat = 6
        static let messageTextViewLeadingPadding: CGFloat = 10
        static let messageTextViewTrailingPadding: CGFloat = 10
        static let messageTextViewMaxWidth: CGFloat = 350
    }
    
    // MARK: - Свойства
    private let messageTextView = UITextView()
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
    
    // MARK: - Настройка UI
    private func setupUI() {
        contentView.addSubview(messageTextView)
        messageTextView.isEditable = false
        messageTextView.isScrollEnabled = false
        messageTextView.font = UIFont(name: "Nunito-Regular", size: 17)
        messageTextView.textColor = .black
        messageTextView.textContainerInset = UIEdgeInsets(
            top: Constants.messageTextViewTextContainerInsetTop,
            left: Constants.messageTextViewTextContainerInsetLeft,
            bottom: Constants.messageTextViewTextContainerInsetBottom,
            right: Constants.messageTextViewTextContainerInsetRight
        )
        messageTextView.layer.cornerRadius = 20
        messageTextView.clipsToBounds = true
        messageTextView.pinTop(to: contentView.topAnchor, Constants.messageTextViewTopPadding)
        messageTextView.pinBottom(to: contentView.bottomAnchor, Constants.messageTextViewBottomPadding)
        leadingConstraint = messageTextView.pinLeft(to: contentView.leadingAnchor, Constants.messageTextViewLeadingPadding)
        trailingConstraint = messageTextView.pinRight(to: contentView.trailingAnchor, Constants.messageTextViewTrailingPadding)
        maxWidthConstraint = messageTextView.setWidth(mode: .lsOE, Constants.messageTextViewMaxWidth) // Максимальная ширина отправленного сообщения
    }
    
    func configure(with message: Message) {
        messageTextView.text = message.text
        messageTextView.layer.borderWidth = 0
        messageTextView.layer.borderColor = UIColor.clear.cgColor
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false
        if message.isUser {
            messageTextView.backgroundColor = .color300
            messageTextView.textAlignment = .right
            messageTextView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner
            ]
            trailingConstraint.isActive = true
        } else {
            messageTextView.backgroundColor = .white
            messageTextView.layer.borderWidth = 1
            messageTextView.layer.borderColor = UIColor.color300.cgColor
            messageTextView.textAlignment = .left
            messageTextView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner
            ]
            leadingConstraint.isActive = true
        }
    }
}
