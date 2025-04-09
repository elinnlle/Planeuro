//
//  ScheduleTaskCell.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 08.04.2025.
//

import UIKit

class ScheduleTaskCell: UICollectionViewCell {
    
    // MARK: Константы
    
    private enum Constants {
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat   = 5
        static let stackSpacing: CGFloat      = 10
        static let containerCornerRadius: CGFloat = 20
        static let containerBorderWidth: CGFloat   = 1
        static let containerInnerTopBottom: CGFloat = 5
        static let containerInnerLeftRight: CGFloat = 10
        static let timeLabelWidth: CGFloat      = 60
        static let titleFontSize: CGFloat  = 20
        static let detailFontSize: CGFloat = 14
        static let hourMinutes: Int = 60
        
    }

    // MARK: - Subviews
    
    private let timeLabel   = UILabel()
    private let titleLabel  = UILabel()
    private let detailLabel = UILabel()
    private let container   = UIView()

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        timeLabel.font      = UIFont(name: "Nunito-Regular", size: Constants.titleFontSize)
        timeLabel.textColor = .black

        titleLabel.font     = UIFont(name: "Nunito-Regular", size: Constants.titleFontSize)
        detailLabel.font    = UIFont(name: "Nunito-Regular", size: Constants.detailFontSize)

        let vstack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        vstack.axis = .vertical

        container.layer.cornerRadius = Constants.containerCornerRadius
        container.layer.borderWidth  = Constants.containerBorderWidth
        container.addSubview(vstack)

        let hstack = UIStackView(arrangedSubviews: [container, timeLabel])
        hstack.axis      = .horizontal
        hstack.alignment = .center
        hstack.spacing   = Constants.stackSpacing
        
        contentView.addSubview(hstack)
        
        hstack.pinTop(to: contentView.topAnchor, Constants.verticalPadding)
        hstack.pinBottom(to: contentView.bottomAnchor, Constants.containerInnerTopBottom)
        hstack.pinLeft(to: contentView.leadingAnchor, Constants.horizontalPadding)
        hstack.pinRight(to: contentView.trailingAnchor, Constants.horizontalPadding)
        
        vstack.pinTop(to: container.topAnchor, Constants.verticalPadding)
        vstack.pinBottom(to: container.bottomAnchor, Constants.containerInnerTopBottom)
        vstack.pinLeft(to: container.leadingAnchor, Constants.containerInnerLeftRight)
        vstack.pinRight(to: container.trailingAnchor, Constants.containerInnerLeftRight)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.widthAnchor.constraint(equalToConstant: Constants.timeLabelWidth).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }

    // MARK: - Configuration
    
    func configure(with item: DisplayItem, userColor: UIColor) {
        // общий сброс
        container.layer.borderWidth = 1
        detailLabel.textColor      = .black
        titleLabel.textColor       = .black

        switch item {
        case .greetingMorning(let time, let count):
            timeLabel.isHidden       = false
            timeLabel.text           = DateFormatter.timeOnly.string(from: time)
            titleLabel.text          = "Доброе утро!"
            detailLabel.text         = "На сегодня запланировано " + String.pluralizedTasks(count)
            container.backgroundColor    = .white
            container.layer.borderColor  = UIColor.color700.cgColor
            titleLabel.textColor      = .color700
            detailLabel.textColor     = .color700.withAlphaComponent(0.8)

        case .greetingNight(let time):
            timeLabel.isHidden       = false
            timeLabel.text           = DateFormatter.timeOnly.string(from: time)
            titleLabel.text          = "Доброй ночи!"
            detailLabel.text         = "Не забудьте указать свой прогресс"
            container.backgroundColor    = .white
            container.layer.borderColor  = UIColor.color700.cgColor
            titleLabel.textColor      = .color700
            detailLabel.textColor     = .color700.withAlphaComponent(0.8)

        case .fullDay(let task):
            timeLabel.isHidden = true
            titleLabel.text    = task.title

            // адрес
            let addr = task.address.isEmpty ? "адрес не задан" : task.address

            // проверяем, уложилась ли задача ровно в один день
            let calendar = Calendar.current
            let isSameDay = calendar.isDate(task.startDate, inSameDayAs: task.endDate)

            if isSameDay {
                // однодневная
                let compsStart = calendar.dateComponents([.hour, .minute], from: task.startDate)
                let compsEnd   = calendar.dateComponents([.hour, .minute], from: task.endDate)

                if compsStart.hour == 0, compsStart.minute == 0,
                   compsEnd.hour   == 23, compsEnd.minute   == 59 {
                    // классический «весь день»
                    detailLabel.text = "Весь день, \(addr)"
                } else {
                    // на одном дне, но не весь день (крайне маловероятно для fullDay, но на всякий)
                    let timeFmt = DateFormatter()
                    timeFmt.dateFormat = "dd MMM, HH:mm"
                    timeFmt.locale = Locale(identifier: "ru_RU")
                    let start = timeFmt.string(from: task.startDate)
                    let end   = timeFmt.string(from: task.endDate)
                    detailLabel.text = "\(start) – \(end), \(addr)"
                }

            } else {
                // много­дневная — показываем полный период
                let fmt = DateFormatter()
                fmt.dateFormat = "dd MMM, HH:mm"
                fmt.locale = Locale(identifier: "ru_RU")
                let start = fmt.string(from: task.startDate)
                let end   = fmt.string(from: task.endDate)
                detailLabel.text = "\(start) – \(end), \(addr)"
            }

            container.backgroundColor    = (task.type == .userDefined)
                                        ? UIColor.color300
                                        : .white
            container.layer.borderColor  = UIColor.color300.cgColor

        case .travel(let time, let duration):
            timeLabel.isHidden       = false
            timeLabel.text           = DateFormatter.timeOnly.string(from: time)
            titleLabel.text          = "Время на дорогу"
            if duration >= Constants.hourMinutes {
                let h = duration / Constants.hourMinutes
                let m = duration % Constants.hourMinutes
                detailLabel.text = m == 0 ? "\(h) ч" : "\(h) ч \(m) мин"
            } else {
                detailLabel.text = "\(duration) мин"
            }
            container.backgroundColor    = .white
            container.layer.borderColor  = UIColor.color300.cgColor
            titleLabel.textColor      = UIColor.color300
            detailLabel.textColor     = UIColor.color300

        case .task(let time, let task):
            timeLabel.isHidden       = false
            timeLabel.text           = DateFormatter.timeOnly.string(from: time)
            titleLabel.text          = task.title
            let addr = task.address.isEmpty ? "адрес не задан" : task.address
            let start = DateFormatter.timeOnly.string(from: task.startDate)
            let end   = DateFormatter.timeOnly.string(from: task.endDate)
            detailLabel.text         = "\(start)–\(end), \(addr)"
            let isHighlighted = (task.type == .userDefined || task.type == .aiRecommendation)
            container.backgroundColor   = isHighlighted ? UIColor.color300 : .white
            container.layer.borderColor = UIColor.color300.cgColor

        case .gap(let start, let end):
            timeLabel.isHidden = false
            timeLabel.text     = DateFormatter.timeOnly.string(from: start)

            let minutes = Int(end.timeIntervalSince(start) / Double(Constants.hourMinutes))
            if minutes < Constants.hourMinutes {
                titleLabel.text = "Свободно \(minutes) минут"
            } else {
                let h = minutes / Constants.hourMinutes
                let m = minutes % Constants.hourMinutes
                if m == 0 {
                    titleLabel.text = "Свободно \(h) ч"
                } else {
                    titleLabel.text = "Свободно \(h) ч \(m) мин"
                }
            }
            
            let enabled = UserDefaults.standard.bool(forKey: "recommendationsEnabled")
            detailLabel.text = enabled
                    ? "Зажмите для получения рекомендаций"
                    : "Рекомендации отключены"
            
            container.backgroundColor    = .white
            container.layer.borderColor  = UIColor.color300.cgColor
            titleLabel.textColor         = UIColor.color300
            detailLabel.textColor        = UIColor.color300
        }
    }
}

// MARK: - DateFormatter Extension

private extension DateFormatter {
    static let timeOnly: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}

// MARK: - String Extension

extension String {
    /// Возвращает форму слова "дело" с учётом числа
    static func pluralizedTasks(_ count: Int) -> String {
        let mod100 = count % 100
        let mod10  = count % 10

        if mod100 >= 11 && mod100 <= 14 {
            return "\(count) дел"
        } else if mod10 == 1 {
            return "\(count) дело"
        } else if mod10 >= 2 && mod10 <= 4 {
            return "\(count) дела"
        } else {
            return "\(count) дел"
        }
    }
}

