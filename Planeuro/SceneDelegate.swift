//
//  SceneDelegate.swift
//  Planeuro
//
//  Created by Эльвира Матвеенко on 14.01.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        
        // Создание экземпляра Presenter и Interactor для экрана входа
        let presenter = LoginPresenter()
        let interactor = LoginInteractor(presenter: presenter)
        let loginViewController = LoginViewController(interactor: interactor)
        
        // Встраиваем экран входа в NavigationController
        let navigationController = UINavigationController(rootViewController: loginViewController)
        
        // Устанавливаем rootViewController
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

