//
//  LocationSettings.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.04.2025.
//

import UIKit

@objcMembers
class LocationSettings: UIView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let placeholderText = "Адрес не задан"
        static let placeholderTextColor = UIColor.black
        static let addressFontName = "Nunito-ExtraBold"
        static let addressFontSize: CGFloat = 20
        static let labelFontName = "Nunito-Regular"
        static let labelFontSize: CGFloat = 14
        static let labelDefaultText = "Время на дорогу не задано"
        static let textColor = UIColor.black
        static let textAlignment: NSTextAlignment = .center
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 20
        static let topPadding: CGFloat = 8
        static let sidePadding: CGFloat = 8
        static let spacingBetweenFields: CGFloat = 2
        static let bottomPadding: CGFloat = 8
        static let hourMinutes: Int = 8
    }
    
    // MARK: - UI Elements

    private let locationTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: Constants.placeholderText,
            attributes: [.foregroundColor: Constants.placeholderTextColor]
        )
        tf.font = UIFont(name: Constants.addressFontName, size: Constants.addressFontSize)
        tf.textColor = Constants.textColor
        tf.textAlignment = Constants.textAlignment
        tf.borderStyle = .none
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    private let travelTimeLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.labelDefaultText
        label.font = UIFont(name: Constants.labelFontName, size: Constants.labelFontSize)
        label.textColor = Constants.textColor
        label.textAlignment = Constants.textAlignment
        label.isUserInteractionEnabled = false
        return label
    }()
    
    // MARK: - Public Properties

    var onEditLocation: (() -> Void)?
    
    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
    
    // MARK: - Private Methods

    private func setupView() {
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.color500.cgColor
        layer.cornerRadius = Constants.cornerRadius
        
        addSubview(locationTextField)
        addSubview(travelTimeLabel)
    }
    
    private func setupLayout() {
        locationTextField.pinTop(to: topAnchor, Constants.topPadding)
        locationTextField.pinLeft(to: leadingAnchor, Constants.sidePadding)
        locationTextField.pinRight(to: trailingAnchor, Constants.sidePadding)
        
        travelTimeLabel.pinTop(to: locationTextField.bottomAnchor, Constants.spacingBetweenFields)
        travelTimeLabel.pinLeft(to: leadingAnchor, Constants.sidePadding)
        travelTimeLabel.pinRight(to: trailingAnchor, Constants.sidePadding)
        travelTimeLabel.pinBottom(to: bottomAnchor, Constants.bottomPadding)
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLocationTap))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleLocationTap() {
        onEditLocation?()
    }
    
    // MARK: - Public Methods

    func updateAddress(_ address: String) {
        locationTextField.text = address
    }
    
    func updateTravelTime(_ minutes: Int) {
        if minutes > 0 {
            if minutes >= Constants.hourMinutes {
                let hours = minutes / Constants.hourMinutes
                let minutesRemainder = minutes % Constants.hourMinutes
                let hoursText = "\(hours) ч"
                let minutesText = minutesRemainder > 0 ? " \(minutesRemainder) мин" : ""
                travelTimeLabel.text = "Время на дорогу: \(hoursText)\(minutesText)"
            } else {
                travelTimeLabel.text = "Время на дорогу: \(minutes) мин"
            }
        } else {
            travelTimeLabel.text = Constants.labelDefaultText
        }
    }
}
