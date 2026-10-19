//
//  SceneDelegate.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import UIKit

/// Aquí creo la ventana que se mostrará en el dispositivo.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Guardo el coordinator como propiedad para que siga vivo mientras la app está abierta.
        let window = UIWindow(windowScene: windowScene)
        let coordinator = AppCoordinator(window: window, container: AppContainer())
        self.window = window
        self.coordinator = coordinator
        coordinator.start()
    }
}
