//
//  CalendarDayCell.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 05.02.2025.
//

import UIKit

class CalendarDayCell: UICollectionViewCell {
    
    var cellDate: Date?  // Дата, соответствующая ячейке
    
    private enum Constants {
        static let dayLabelFontSize: CGFloat = 17.0
        static let todayBorderWidth: CGFloat = 1.0
        static let cornerRadius: CGFloat = 15.0
    }
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "NunitoSans-Regular", size: Constants.dayLabelFontSize)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(dayLabel)
        dayLabel.pinCenter(to: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with day: Int,
                   isCurrentMonth: Bool,
                   isToday: Bool,
                   isSelected: Bool,
                   textColor: UIColor) {
        
        dayLabel.text = day == 0 ? "" : "\(day)"
        dayLabel.textColor = textColor
        
        contentView.backgroundColor = .white
        contentView.layer.borderColor = nil
        contentView.layer.borderWidth = 0
        contentView.layer.cornerRadius = 0
        
        if isToday {
            dayLabel.textColor = .color500
            contentView.layer.borderColor = UIColor.color500.cgColor
            contentView.layer.borderWidth = Constants.todayBorderWidth
            contentView.layer.cornerRadius = Constants.cornerRadius
        }
        
        if isSelected {
            contentView.backgroundColor = .color500
            contentView.layer.cornerRadius = Constants.cornerRadius
            dayLabel.textColor = .white
        }
    }
}
