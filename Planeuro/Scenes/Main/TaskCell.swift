//
//  TaskCell.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 20.01.2025.
//

import UIKit

final class TaskCell: UITableViewCell {
    
    // MARK: - Константы
    
    private enum Constants {
        static let cellPadding: CGFloat = 20
        static let contentPadding: CGFloat = 10
        static let categorySize: CGFloat = 20
        static let statusHeight: CGFloat = 20
        static let separatorHeight: CGFloat = 1
        static let contentCornerRadius: CGFloat = 20
        static let statusCornerRadius: CGFloat = 10
        static let contentBorderWidth: CGFloat = 1
        static let taskHeight: CGFloat = 90
        static let separatorOffset: CGFloat = 30
        
    }
    
    // MARK: - Свойства
    
    private let categoryIndicator = UIView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusLabel = UILabel()
    private let separatorView = UIView()
    
    // MARK: - Инициализация
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupStyles()
        selectionStyle = .none
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Настройка UI
    
    private func setupViews() {
        [categoryIndicator, titleLabel, addressLabel, dateLabel, statusLabel, separatorView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupStyles() {
        setupCategoryIndicator()
        setupTitleLabel()
        setupAddressLabel()
        setupDateLabel()
        setupStatusLabel()
        setupSeparator()
        setupContentView()
    }
    
    private func setupContentView() {
        contentView.layer.cornerRadius = Constants.contentCornerRadius
        contentView.layer.borderWidth = Constants.contentBorderWidth
        contentView.layer.borderColor = UIColor.color500.cgColor
        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
    }
    
    private func setupCategoryIndicator() {
        categoryIndicator.layer.cornerRadius = Constants.categorySize / 2
        categoryIndicator.clipsToBounds = true
    }
    
    private func setupTitleLabel() {
        titleLabel.font = UIFont(name: "Nunito-Regular", size: 20)
        titleLabel.textColor = .black
    }
    
    private func setupAddressLabel() {
        addressLabel.font = UIFont(name: "Nunito-Regular", size: 14)
        addressLabel.textColor = .black
    }
    
    private func setupDateLabel() {
        dateLabel.font = UIFont(name: "Nunito-Regular", size: 14)
        dateLabel.textColor = .color800
    }
    
    private func setupStatusLabel() {
        statusLabel.font = UIFont(name: "Nunito-Regular", size: 14)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .white
        statusLabel.layer.backgroundColor = UIColor.color500.cgColor
        statusLabel.layer.cornerRadius = Constants.statusCornerRadius
        statusLabel.layer.masksToBounds = true
    }
    
    private func setupSeparator() {
        separatorView.layer.backgroundColor = UIColor.color500.cgColor
    }
    
    // MARK: - Конфигурация данных
    
    func configure(with task: Task) {
        titleLabel.text = task.title
        addressLabel.text = task.address
        dateLabel.text = task.date
        statusLabel.text = task.isActive ? "Активная" : "Выполненная"
        categoryIndicator.backgroundColor = task.categoryColor
    }
    
    // MARK: - Разметка
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let taskWidth = contentView.bounds.width
        
        // Центрирование contentView
        contentView.frame = CGRect(
            x: Constants.cellPadding,
            y: Constants.contentPadding,
            width: taskWidth - 2 * Constants.cellPadding,
            height: Constants.taskHeight
        )
        
        // Размещение элементов
        categoryIndicator.frame = CGRect(
            x: contentView.frame.width - Constants.categorySize - Constants.contentPadding,
            y: Constants.contentPadding,
            width: Constants.categorySize,
            height: Constants.categorySize
        )
        
        titleLabel.frame = CGRect(
            x: 2 * Constants.contentPadding,
            y: Constants.contentPadding,
            width: taskWidth - Constants.categorySize - 3 * Constants.contentPadding - Constants.statusHeight,
            height: 20
        )
        titleLabel.sizeToFit()
        
        addressLabel.frame = CGRect(
            x: 2 * Constants.contentPadding,
            y: titleLabel.frame.maxY - 2,
            width: taskWidth - Constants.categorySize - 1.5 * Constants.contentPadding - Constants.statusHeight,
            height: 20
        )
        addressLabel.sizeToFit()
        
        dateLabel.frame = CGRect(
            x: 2 * Constants.contentPadding,
            y: Constants.taskHeight - 24,
            width: taskWidth - Constants.categorySize - 1.5 * Constants.contentPadding - Constants.statusHeight,
            height: 20
        )
        dateLabel.sizeToFit()
        
        let statusTextWidth = statusLabel.intrinsicContentSize.width + 16
        statusLabel.frame = CGRect(
            x: contentView.frame.width - statusTextWidth - Constants.contentPadding,
            y: Constants.taskHeight - 25,
            width: statusTextWidth,
            height: Constants.statusHeight
        )
        
        separatorView.frame = CGRect(
            x: 0,
            y: contentView.bounds.height - Constants.separatorOffset,
            width: contentView.bounds.width,
            height: Constants.separatorHeight
        )
    }
}
