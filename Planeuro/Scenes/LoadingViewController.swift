//
//  LoadingViewController.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 19.01.2025.
//

import UIKit

class LoadingViewController: UIViewController {
    
    // MARK: - Константы
    private enum Constants {
        static let appNameFontSize: CGFloat = 45.0
        static let versionFontSize: CGFloat = 17.0
        static let appIconSize: CGFloat = 200.0
        static let labelToIconSpacing: CGFloat = 20.0
        static let bottomLabelSpacing: CGFloat = 30.0
        static let labelCenterYOffset: CGFloat = -140.0
        static let loadingDelay: TimeInterval = 2.0
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        performLoginCheck()
    }

    // MARK: - Настройка интерфейса
    private func setupUI() {
        view.backgroundColor = .white

        // Название приложения
        let label = UILabel()
        label.text = "Planeuro"
        label.font = UIFont(name: "Nunito-Black", size: Constants.appNameFontSize)
        label.textColor = .color800
        label.textAlignment = .center
        view.addSubview(label)

        // Иконка приложения
        let appIconImageView = UIImageView()
        appIconImageView.image = UIImage(named: "PlaneuroIcon.png")
        appIconImageView.contentMode = .scaleAspectFit
        view.addSubview(appIconImageView)

        // Версия приложения
        let versionLabel = UILabel()
        versionLabel.text = "Версия 1.0.0"
        versionLabel.font = UIFont(name: "Nunito-Regular", size: Constants.versionFontSize)
        versionLabel.textColor = .black
        versionLabel.textAlignment = .center
        view.addSubview(versionLabel)

        // Центрирование названия и иконки приложения
        label.pinCenterX(to: view)
        label.pinCenterY(to: view, Constants.labelCenterYOffset)

        appIconImageView.pinCenterX(to: view)
        appIconImageView.pinTop(to: label.bottomAnchor, Constants.labelToIconSpacing)
        appIconImageView.setWidth(mode: .equal, Constants.appIconSize)
        appIconImageView.setHeight(mode: .equal, Constants.appIconSize)

        // Расположение версии приложения
        versionLabel.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, Constants.bottomLabelSpacing)
        versionLabel.pinCenterX(to: view)
    }

    // MARK: - Проверка состояния входа
    private func performLoginCheck() {
        // Имитируем загрузку с помощью задержки
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            // Проверяем, авторизован ли пользователь
            if AuthManager.shared.isUserLoggedIn() {
                self.navigateToMain()
            } else {
                self.navigateToLogin()
            }
        }
    }

    // MARK: - Переход на главный экран
    private func navigateToMain() {
        let mainViewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        transitionToRootViewController(navigationController)
    }

    // MARK: - Переход на экран входа
    private func navigateToLogin() {
        let presenter = LoginPresenter()
        let interactor = LoginInteractor(presenter: presenter)
        let loginViewController = LoginViewController(interactor: interactor, presenter: presenter)
        let navigationController = UINavigationController(rootViewController: loginViewController)
        transitionToRootViewController(navigationController)
    }

    // MARK: - Плавный переход между rootViewController
    private func transitionToRootViewController(_ viewController: UIViewController) {
        guard let windowScene = view.window?.windowScene else { return }
        guard let window = windowScene.windows.first else { return }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}
