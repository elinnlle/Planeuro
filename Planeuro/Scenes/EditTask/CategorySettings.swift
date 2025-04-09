//
//  CategorySettings.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 07.04.2025.
//

import UIKit

@objcMembers
class CategorySettings: UICollectionViewCell {
    
    // MARK: - Constants
    
    private enum Constants {
        static let circleRadius: CGFloat = 7
        static let circleSize: CGFloat = 14
        static let hStackSpacing: CGFloat = 6
        static let hStackHorizontalPadding: CGFloat = 7
        static let cornerRadius: CGFloat = 12
        static let titleFontName: String = "Nunito-Regular"
        static let titleFontSize: CGFloat = 14
        static let plusIconName: String = "PlusCategoryIcon"
        static let backgroundAlpha: CGFloat = 0.15
    }
    
    // MARK: - UI Elements
    
    /// Цветной кружок слева
    private let colorCircle: UIView = {
        let circle = UIView()
        circle.layer.cornerRadius = Constants.circleRadius
        circle.layer.masksToBounds = true
        return circle
    }()
    
    /// Текстовое поле для названия категории
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Constants.titleFontName, size: Constants.titleFontSize)
        label.textColor = .black
        return label
    }()
    
    /// Горизонтальный стек с отступами
    private lazy var hStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [colorCircle, titleLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Constants.hStackSpacing
        return stack
    }()
    
    /// ImageView для кнопки добавления (иконка PlusCategoryIcon)
    private let plusIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: Constants.plusIconName))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(hStack)
        contentView.addSubview(plusIconView)
        
        hStack.pinLeft(to: contentView.leadingAnchor, Constants.hStackHorizontalPadding)
        hStack.pinRight(to: contentView.trailingAnchor, Constants.hStackHorizontalPadding)
        hStack.pinCenterY(to: contentView.centerYAnchor)
        
        plusIconView.pinCenter(to: contentView)
        
        colorCircle.setWidth(Constants.circleSize)
        colorCircle.setHeight(Constants.circleSize)
    }
    
    // MARK: - Configuration
    
    /// Конфигурация для обычной категории
    func configure(with title: String, color: UIColor) {
        hStack.isHidden = false
        colorCircle.isHidden = false
        titleLabel.isHidden = false
        plusIconView.isHidden = true
        
        titleLabel.text = title
        colorCircle.backgroundColor = color
        contentView.backgroundColor = color.withAlphaComponent(Constants.backgroundAlpha)
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
    
    /// Конфигурация для кнопки добавления
    func configureAsAddButton(color: UIColor) {
        hStack.isHidden = true
        plusIconView.isHidden = false
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.backgroundColor = .clear
    }
}
