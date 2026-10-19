//
//  AppDelegate.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import UIKit

/// Este es el primer punto que llama iOS cuando abre la aplicación.
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // No uso un storyboard principal porque la ventana se arma en SceneDelegate.
        UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    }
}
