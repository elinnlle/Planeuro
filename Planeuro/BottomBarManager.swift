//
//  BottomBarManager.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 03.02.2025.
//

import UIKit

// MARK: - Конфигурация для BottomBar
struct BottomBarConfiguration {
    var icons: [String] // Массив иконок
    var gradientImage: String

    // Дефолтная конфигурация
    static var `default`: BottomBarConfiguration {
        BottomBarConfiguration(
            icons: ["HomeIcon", "CalendarIconAdd", "SettingsIconAdd"],
            gradientImage: "Gradient"
        )
    }
}

class BottomBarManager {
    
    // MARK: - Свойства
    
    private weak var view: UIView?
    private var barView: UIView?
    private var gradientView: UIImageView?
    private var isDragging: Bool = false
    private var previousScrollOffset: CGFloat = 0
    private let configuration: BottomBarConfiguration
    
    // MARK: - Константы
    
    private enum Constants {
        static let barCornerRadius: CGFloat = 20.0
        static let barHeight: CGFloat = 70.0
        static let barBottomOffset: CGFloat = -5.0
        static let buttonSize: CGFloat = 40.0
        static let buttonOffset: CGFloat = 25.0
        static let gradientViewBottomOffset: CGFloat = -90.0
        static let gradientViewHeight: CGFloat = 400.0
        static let barTransformOffsetY: CGFloat = 120.0
        static let gradientTransformOffsetY: CGFloat = 170.0
    }
    
    // MARK: - Инициализация
    
    init(view: UIView, configuration: BottomBarConfiguration = .default) {
        self.view = view
        self.configuration = configuration
        setupBar()
    }
    
    // MARK: - Настройка бара
    
    private func setupBar() {
        guard let view = view, !configuration.icons.isEmpty else { return }
        
        let iconCount = configuration.icons.count
        let barWidth = CGFloat(iconCount) * Constants.buttonSize + CGFloat(iconCount + 1) * Constants.buttonOffset
        
        barView = UIView()
        barView?.backgroundColor = UIColor.color500
        barView?.layer.cornerRadius = Constants.barCornerRadius
        barView?.layer.zPosition = 1
        view.addSubview(barView!)
        
        gradientView = UIImageView()
        gradientView?.image = UIImage(named: configuration.gradientImage)
        gradientView?.contentMode = .scaleAspectFit
        view.addSubview(gradientView!)
        
        var previousButton: UIButton?
        
        // Создание кнопок для бара
        for icon in configuration.icons {
            let button = UIButton()
            button.setImage(UIImage(named: icon), for: .normal)
            // Сохраняем имя иконки для определения действия при нажатии
            button.accessibilityIdentifier = icon
            // Добавляем обработчик нажатия
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            barView?.addSubview(button)
            
            button.pinCenterY(to: barView!)
            button.setWidth(mode: .equal, Constants.buttonSize)
            button.setHeight(mode: .equal, Constants.buttonSize)
            
            if let previous = previousButton {
                button.pinLeft(to: previous.trailingAnchor, Constants.buttonOffset)
            } else {
                button.pinLeft(to: barView!.leadingAnchor, Constants.buttonOffset)
            }
            
            previousButton = button
        }
        
        // Добавление ограничений для бара
        barView?.pinCenterX(to: view)
        barView?.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Constants.barBottomOffset)
        barView?.setWidth(mode: .equal, barWidth)
        barView?.setHeight(mode: .equal, Constants.barHeight)
        
        // Установка ограничений для gradientView
        gradientView?.pinLeft(to: view.leadingAnchor)
        gradientView?.pinRight(to: view.trailingAnchor)
        gradientView?.pinBottom(to: view.bottomAnchor, Constants.gradientViewBottomOffset)
        gradientView?.setHeight(mode: .equal, Constants.gradientViewHeight)
    }
    
    // MARK: - Обработка нажатия на кнопку
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let iconName = sender.accessibilityIdentifier,
              let parentVC = view?.parentViewController else { return }
        
        // Если нажата иконка для главного экрана
        if iconName == "HomeIcon" || iconName == "HomeIconAdd" {
            let mainVC = MainViewController()
            parentVC.navigationController?.pushViewController(mainVC, animated: false)
        }
        // Если нажата иконка для календаря
        else if iconName == "CalendarIcon" || iconName == "CalendarIconAdd" {
            let calendarVC = CalendarViewController()
            parentVC.navigationController?.pushViewController(calendarVC, animated: false)
        }
        // Если нажата иконка для настроек
        else if iconName == "SettingsIcon" || iconName == "SettingsIconAdd" {
            let calendarVC = SettingsViewController()
            parentVC.navigationController?.pushViewController(calendarVC, animated: false)
        }
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

// MARK: - Расширение для получения родительского ViewController
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            if let vc = responder as? UIViewController {
                return vc
            }
            parentResponder = responder.next
        }
        return nil
    }
}

// MARK: - Расширения для UIScrollViewDelegate в контроллерах
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

extension CalendarViewController: UIScrollViewDelegate {
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

extension SettingsViewController: UIScrollViewDelegate {
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
