//
//  AppDelegate.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 14.01.2025.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Создание экземпляра Presenter
        let presenter = LoginPresenter()

        // Создание экземпляра Interactor, передача Presenter
        let interactor = LoginInteractor(presenter: presenter)

        // Создание экземпляра ViewController, передача Interactor
        let viewController = LoginViewController(interactor: interactor)

        // Инициализация окна и установка главного экрана
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        return true
    }
}
