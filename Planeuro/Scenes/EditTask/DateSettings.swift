//
//  DateSettings.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.04.2025.
//

import UIKit

@objcMembers
class DateSettings: UICollectionViewCell {
    
    // MARK: - Constants
    
    private enum Constants {
        static let cornerRadius: CGFloat = 20
        static let borderWidth: CGFloat = 1
        static let dayFontName = "Nunito-ExtraBold"
        static let monthFontName = "Nunito-Regular"
        static let dayFontSize: CGFloat = 20
        static let monthFontSize: CGFloat = 14
        static let stackSpacing: CGFloat = 4
        static let dayDateFormat = "d"
        static let monthDateFormat = "MMM"
        static let downArrowImageName = "DownArrowIcon"
    }
    
    // MARK: - UI Elements
    
    private let dayLabel = UILabel()
    private let monthLabel = UILabel()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layer.borderWidth = Constants.borderWidth
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        
        dayLabel.font = UIFont(name: Constants.dayFontName, size: Constants.dayFontSize)
        dayLabel.textColor = .black
        dayLabel.textAlignment = .center
        
        monthLabel.font = UIFont(name: Constants.monthFontName, size: Constants.monthFontSize)
        monthLabel.textAlignment = .center
        monthLabel.textColor = .black
        
        let stack = UIStackView(arrangedSubviews: [dayLabel, monthLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Constants.stackSpacing
        
        contentView.addSubview(stack)
        stack.pinCenter(to: contentView)
    }
    
    // MARK: - Configuration
    
    func configure(dayNumber: String, dayName: String) {
        dayLabel.text = dayNumber
        monthLabel.text = dayName
    }
    
    func updateCellSelectedState(_ selected: Bool) {
        if selected {
            contentView.backgroundColor = .color500
            dayLabel.textColor = .white
            monthLabel.textColor = .white
            contentView.layer.borderColor = UIColor.color500.cgColor
        } else {
            contentView.backgroundColor = .white
            dayLabel.textColor = .black
            monthLabel.textColor = .black
            contentView.layer.borderColor = UIColor.color500.cgColor
        }
    }
    
    func configureDate(_ date: Date, referenceDate: Date) {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = Constants.dayDateFormat
        let dayString = dayFormatter.string(from: date)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = Constants.monthDateFormat
        let monthString = monthFormatter.string(from: date)
        
        configure(dayNumber: dayString, dayName: monthString)
        
        let isSameDay = Calendar.current.isDate(date, inSameDayAs: referenceDate)
        updateCellSelectedState(isSameDay)
    }
    
    // MARK: - Helpers
    
    static func createDownArrowView() -> UICollectionReusableView {
        let footerView = UICollectionReusableView()
        let imageView = UIImageView(image: UIImage(named: Constants.downArrowImageName))
        imageView.contentMode = .center
        footerView.addSubview(imageView)
        imageView.pinCenter(to: footerView)
        return footerView
    }
}
