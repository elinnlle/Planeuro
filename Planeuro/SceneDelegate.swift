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
        
        // Устанавливаем LoadingViewController как стартовый экран
        let mainVC = LoadingViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        window?.tintColor = UIColor.color700
        window?.overrideUserInterfaceStyle = .light // светлая тема
        window?.makeKeyAndVisible()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
            // Пользователь «зашел» в приложение сегодня
            VisitManager.shared.recordVisit()
        }
}


