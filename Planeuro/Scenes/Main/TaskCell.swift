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
        
        static let titleFontSize: CGFloat = 20
        static let subtitleFontSize: CGFloat = 14
        
        static let dateBottomOffset: CGFloat = 24
        static let statusBottomOffset: CGFloat = 25
        static let statusHorizontalPadding: CGFloat = 16
    }

    
    // MARK: - UI Элементы
    private let categoryIndicator = UIView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusLabel = UILabel()
    private let separatorView = UIView()
    
    var showsStatus: Bool = true {
        didSet {
            statusLabel.isHidden = !showsStatus
        }
    }
    
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
        // contentView
        contentView.layer.cornerRadius = Constants.contentCornerRadius
        contentView.layer.borderWidth = Constants.contentBorderWidth
        contentView.layer.borderColor = UIColor.color500.cgColor
        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
        
        // categoryIndicator
        categoryIndicator.layer.cornerRadius = Constants.categorySize / 2
        categoryIndicator.clipsToBounds = true
        
        // titleLabel
        titleLabel.font = UIFont(name: "Nunito-Regular", size: Constants.titleFontSize)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        
        // addressLabel
        addressLabel.font = UIFont(name: "Nunito-Regular", size: Constants.subtitleFontSize)
        addressLabel.textColor = .black
        addressLabel.numberOfLines = 1
        addressLabel.lineBreakMode = .byTruncatingTail
        
        // dateLabel
        dateLabel.font = UIFont(name: "Nunito-Regular", size: Constants.subtitleFontSize)
        dateLabel.textColor = .color800
        
        // statusLabel
        statusLabel.font = UIFont(name: "Nunito-Regular", size: Constants.subtitleFontSize)
        statusLabel.textAlignment = .center
        statusLabel.textColor = .white
        statusLabel.layer.backgroundColor = UIColor.color500.cgColor
        statusLabel.layer.cornerRadius = Constants.statusCornerRadius
        statusLabel.layer.masksToBounds = true
        
        // separatorView
        separatorView.layer.backgroundColor = UIColor.color500.cgColor
    }
    
    // MARK: - Конфигурация данных
    func configure(with task: Tasks) {
        // title
        titleLabel.text = task.title
        
        let fullAddress = task.address.trimmingCharacters(in: .whitespacesAndNewlines)
        addressLabel.text = fullAddress.isEmpty ? "Адрес не задан" : fullAddress
        
        // date
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMM, HH:mm"
        let startString = formatter.string(from: task.startDate)
        let endString   = formatter.string(from: task.endDate)
        
        if Calendar.current.isDate(task.startDate, inSameDayAs: task.endDate) {
            let day: String = {
                if Calendar.current.isDateInToday(task.startDate)    { return "Сегодня" }
                if Calendar.current.isDateInTomorrow(task.startDate) { return "Завтра" }
                if Calendar.current.isDateInYesterday(task.startDate){ return "Вчера" }
                let df = DateFormatter(); df.locale = Locale(identifier: "ru_RU"); df.dateFormat = "dd MMM"
                return df.string(from: task.startDate)
            }()
            
            let compsStart = Calendar.current.dateComponents([.hour, .minute], from: task.startDate)
            let compsEnd   = Calendar.current.dateComponents([.hour, .minute], from: task.endDate)
            
            if compsStart.hour == 0, compsStart.minute == 0,
               compsEnd.hour   == 23, compsEnd.minute   == 59 {
                dateLabel.text = "\(day), весь день"
            } else {
                let tf = DateFormatter(); tf.locale = Locale(identifier: "ru_RU"); tf.dateFormat = "HH:mm"
                dateLabel.text = "\(day), \(tf.string(from: task.startDate)) - \(tf.string(from: task.endDate))"
            }
        } else {
            dateLabel.text = "\(startString) - \(endString)"
        }
        
        // status
        switch task.status {
        case .active:    statusLabel.text = "Активная"
        case .completed: statusLabel.text = "Выполненная"
        case .overdue:   statusLabel.text = "Просроченная"
        }
        
        // category color
        categoryIndicator.backgroundColor = task.categoryColor
        
        // hide/show
        statusLabel.isHidden = !showsStatus
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        let totalWidth = bounds.width
        
        contentView.frame = CGRect(
            x: Constants.cellPadding,
            y: Constants.contentPadding,
            width: totalWidth - 2*Constants.cellPadding,
            height: Constants.taskHeight
        )
        
        categoryIndicator.frame = CGRect(
            x: contentView.frame.width - Constants.categorySize - Constants.contentPadding,
            y: Constants.contentPadding,
            width: Constants.categorySize,
            height: Constants.categorySize
        )
        
        // Вычисляем максимальную ширину для заголовка и адреса
        let labelX = Constants.contentPadding * 2
        let rightLimit = categoryIndicator.frame.minX - Constants.contentPadding
        let maxLabelWidth = rightLimit - labelX
        
        titleLabel.frame = CGRect(
            x: labelX,
            y: Constants.contentPadding,
            width: maxLabelWidth,
            height: titleLabel.font.lineHeight
        )
        
        addressLabel.frame = CGRect(
            x: labelX,
            y: titleLabel.frame.maxY - 2,
            width: maxLabelWidth,
            height: addressLabel.font.lineHeight
        )
        
        dateLabel.frame = CGRect(
            x: labelX,
            y: Constants.taskHeight - Constants.dateBottomOffset,
            width: maxLabelWidth,
            height: dateLabel.font.lineHeight
        )
        
        let statusTextWidth = statusLabel.intrinsicContentSize.width + Constants.statusHorizontalPadding
        statusLabel.frame = CGRect(
            x: contentView.frame.width - statusTextWidth - Constants.contentPadding,
            y: Constants.taskHeight - Constants.statusBottomOffset,
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
