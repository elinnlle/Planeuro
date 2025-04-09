//
//  TimeSettings.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.04.2025.
//

import UIKit

@objcMembers
class TimeSettings: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let startTitleText = "От"
        static let endTitleText = "До"
        static let defaultTimeText = "00:00"
        static let titleFontName = "Nunito-Regular"
        static let timeFontName = "Nunito-ExtraBold"
        static let titleFontSize: CGFloat = 14
        static let timeFontSize: CGFloat = 20
        static let titleTextColor = UIColor.black
        static let timeTextColor = UIColor.black
        static let arrowImageName = "RightArrowIcon"
        static let verticalStackSpacing: CGFloat = 2
        static let mainStackSpacing: CGFloat = 40
    }
    
    // MARK: - UI Elements

    private let startTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.startTitleText
        label.font = UIFont(name: Constants.titleFontName, size: Constants.titleFontSize)
        label.textAlignment = .center
        label.textColor = Constants.titleTextColor
        return label
    }()
    
    private let endTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.endTitleText
        label.font = UIFont(name: Constants.titleFontName, size: Constants.titleFontSize)
        label.textAlignment = .center
        label.textColor = Constants.titleTextColor
        return label
    }()
    
    let startTimeLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.defaultTimeText
        label.font = UIFont(name: Constants.timeFontName, size: Constants.timeFontSize)
        label.textAlignment = .center
        label.textColor = Constants.timeTextColor
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let endTimeLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.defaultTimeText
        label.font = UIFont(name: Constants.timeFontName, size: Constants.timeFontSize)
        label.textAlignment = .center
        label.textColor = Constants.timeTextColor
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.arrowImageName)
        imageView.contentMode = .center
        return imageView
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        let startStack = UIStackView(arrangedSubviews: [startTitleLabel, startTimeLabel])
        startStack.axis = .vertical
        startStack.alignment = .center
        startStack.spacing = Constants.verticalStackSpacing
        
        let endStack = UIStackView(arrangedSubviews: [endTitleLabel, endTimeLabel])
        endStack.axis = .vertical
        endStack.alignment = .center
        endStack.spacing = Constants.verticalStackSpacing
        
        let mainStack = UIStackView(arrangedSubviews: [startStack, arrowImageView, endStack])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = Constants.mainStackSpacing
        
        addSubview(mainStack)
        mainStack.pinCenter(to: self)
    }
    
    // MARK: - Public Methods
    
    func configureTimes(startTitle: String, startValue: String, endTitle: String, endValue: String) {
        startTitleLabel.text = startTitle
        startTimeLabel.text = startValue
        endTitleLabel.text = endTitle
        endTimeLabel.text = endValue
    }
}
