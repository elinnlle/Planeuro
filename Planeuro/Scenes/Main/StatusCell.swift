//
//  SatusCell.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 21.01.2025.
//

import UIKit

final class SatusCell: UICollectionViewCell {
    // MARK: - UI Элементы
    
    private let categoryLabel = SatusCell.makeCategoryLabel()
    private let customSelectedBackgroundView = SatusCell.makeSelectedBackgroundView()
    
    // MARK: - Константы
    
    private enum Constants {
        static let labelFontSize: CGFloat = 17.0
        static let cornerRadius: CGFloat = 20.0
        static let borderWidth: CGFloat = 1.0
        static let labelPadding: CGFloat = -12.0
        static let collectionViewHeight: CGFloat = 40.0
        static let additionalWidth: CGFloat = 24.0
    }
    
    // MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Конфигурация
    
    func configure(with category: String, taskCount: Int, isSelected: Bool) {
        categoryLabel.text = "\(category) | \(taskCount)"
        updateSelectionState(isSelected: isSelected)
    }
    
    // MARK: - Размер ячейки
    
    static func size(for category: String, taskCount: Int) -> CGSize {
        let text = "\(category) | \(taskCount)"
        let size = (text as NSString).size(
            withAttributes: [.font: UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)!]
        )
        
        return CGSize(width: size.width + Constants.additionalWidth, height: Constants.collectionViewHeight)
    }
}

// MARK: - Настройка UI

private extension SatusCell {
    // Создание метки для категории
    static func makeCategoryLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "Nunito-Regular", size: Constants.labelFontSize)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
    
    // Создание фона для выделенной ячейки
    static func makeSelectedBackgroundView() -> UIView {
        let view = UIView()
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.borderWidth = Constants.borderWidth
        view.layer.borderColor = UIColor.color500.cgColor
        view.layer.masksToBounds = true
        return view
    }
    
    // Настройка представлений ячейки
    func setupViews() {
        contentView.addSubview(customSelectedBackgroundView)
        contentView.addSubview(categoryLabel)
    }
    
    // Установка ограничений
    func setupConstraints() {
        customSelectedBackgroundView.pinTop(to: contentView)
        customSelectedBackgroundView.pinBottom(to: contentView)
        customSelectedBackgroundView.pinLeft(to: categoryLabel, Constants.labelPadding)
        customSelectedBackgroundView.pinRight(to: categoryLabel, Constants.labelPadding)
        
        categoryLabel.pinCenter(to: contentView)
    }
    
    // Выделяем ячейку при выборе
    func updateSelectionState(isSelected: Bool) {
        customSelectedBackgroundView.backgroundColor = isSelected ? UIColor.color500 : .clear
        categoryLabel.textColor = isSelected ? .white : .black
    }
}
