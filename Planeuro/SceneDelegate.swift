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
        
        let presenter = LoginPresenter()
        let interactor = LoginInteractor(presenter: presenter)
        let registrationViewController = LoginViewController(interactor: interactor)
        
        window?.rootViewController = registrationViewController
        window?.makeKeyAndVisible()
    }

}
