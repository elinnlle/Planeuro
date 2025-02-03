//
//  BottomBarManager.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 03.02.2025.
//

import UIKit

class BottomBarManager {
    
    // MARK: - Свойства
    
    private weak var view: UIView?
    private var barView: UIView?
    private var gradientView: UIImageView?
    private var isDragging: Bool = false
    private var previousScrollOffset: CGFloat = 0
    
    // MARK: - Константы
    
    private enum Constants {
        static let barCornerRadius: CGFloat = 20.0
        static let barWidth: CGFloat = 220.0
        static let barHeight: CGFloat = 70.0
        static let barBottomOffset: CGFloat = -5.0
        static let buttonSize: CGFloat = 40.0
        static let buttonLeftOffset: CGFloat = 25.0
        static let gradientViewBottomOffset: CGFloat = -90.0
        static let gradientViewHeight: CGFloat = 400.0
        static let barTransformOffsetY: CGFloat = 120.0
        static let gradientTransformOffsetY: CGFloat = 170.0
    }
    
    
    // MARK: - Инициализация
    
    init(view: UIView) {
        self.view = view
        setupBar()
    }
    
    // MARK: - Настройка бара
    
    private func setupBar() {
        guard let view = view else { return }
        
        barView = UIView()
        barView?.backgroundColor = UIColor.color500
        barView?.layer.cornerRadius = Constants.barCornerRadius
        barView?.layer.zPosition = 1
        view.addSubview(barView!)
        
        gradientView = UIImageView()
        gradientView?.image = UIImage(named: "Gradient")
        gradientView?.contentMode = .scaleAspectFit
        view.addSubview(gradientView!)
        
        // Создание кнопок для бара
        let homeButton = UIButton()
        homeButton.setImage(UIImage(named: "HomeIcon"), for: .normal)
        barView?.addSubview(homeButton)
        
        let calendarButton = UIButton()
        calendarButton.setImage(UIImage(named: "CalendarIcon"), for: .normal)
        barView?.addSubview(calendarButton)
        
        let settingsButton = UIButton()
        settingsButton.setImage(UIImage(named: "SettingsIcon"), for: .normal)
        barView?.addSubview(settingsButton)
        
        // Добавление ограничений для бара
        barView?.pinCenterX(to: view)
        barView?.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Constants.barBottomOffset)
        barView?.setWidth(mode: .equal, Constants.barWidth)
        barView?.setHeight(mode: .equal, Constants.barHeight)
        
        // Расположение кнопок в баре
        homeButton.pinCenterY(to: barView!)
        homeButton.pinLeft(to: barView!.leadingAnchor, Constants.buttonLeftOffset)
        homeButton.setWidth(mode: .equal, Constants.buttonSize)
        homeButton.setHeight(mode: .equal, Constants.buttonSize)

        calendarButton.pinCenterY(to: barView!)
        calendarButton.pinCenterX(to: barView!)
        calendarButton.setWidth(mode: .equal, Constants.buttonSize)
        calendarButton.setHeight(mode: .equal, Constants.buttonSize)

        settingsButton.pinCenterY(to: barView!)
        settingsButton.pinRight(to: barView!.trailingAnchor, Constants.buttonLeftOffset)
        settingsButton.setWidth(mode: .equal, Constants.buttonSize)
        settingsButton.setHeight(mode: .equal, Constants.buttonSize)
        
        // Установка ограничений для gradientView
        gradientView?.pinLeft(to: view.leadingAnchor)
        gradientView?.pinRight(to: view.trailingAnchor)
        gradientView?.pinBottom(to: view.bottomAnchor, Constants.gradientViewBottomOffset)
        gradientView?.setHeight(mode: .equal, Constants.gradientViewHeight)
    }
    
    // MARK: - Обработка скролла
    
    func handleScroll(_ scrollView: UIScrollView) {
        guard isDragging, let barView = barView, let gradientView = gradientView else { return }
            
        let currentOffset = scrollView.contentOffset.y
        let offsetDifference = currentOffset - previousScrollOffset
            
        // Если прокручиваем вниз, скрываем бар
        if offsetDifference > 0 {
            UIView.animate(withDuration: 0.3) {
                barView.transform = CGAffineTransform(translationX: 0, y: Constants.barTransformOffsetY)
                gradientView.transform = CGAffineTransform(translationX: 0, y: Constants.gradientTransformOffsetY)
            }
        }
        // Если прокручиваем вверх, показываем бар
        else if offsetDifference < 0 {
            UIView.animate(withDuration: 0.3) {
                barView.transform = .identity
                gradientView.transform = .identity
            }
        }
        
        previousScrollOffset = currentOffset
    }
    
    func scrollViewWillBeginDragging() {
        isDragging = true
    }
    
    func scrollViewDidEndDragging() {
        isDragging = false
    }
}

// MARK: - Расширение для MainViewController

extension MainViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        bottomBarManager.scrollViewWillBeginDragging()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        bottomBarManager.handleScroll(scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        bottomBarManager.scrollViewDidEndDragging()
    }
}
