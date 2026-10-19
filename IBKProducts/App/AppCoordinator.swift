//
//  AppCoordinator.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import UIKit

/// Se encarga de armar las pestañas y movernos entre las pantallas.
@MainActor
final class AppCoordinator {
    private let window: UIWindow
    private let container: AppContainer
    private let tabBarController = UITabBarController()
    private let productsNavigation = UINavigationController()
    private let menuNavigation = UINavigationController()

    init(window: UIWindow, container: AppContainer) {
        self.window = window
        self.container = container
    }

    /// Aquí preparo la pestaña de productos y la pestaña del menú.
    func start() {
        configureNavigationBars()

        // La lista avisa qué producto se tocó y el coordinator abre su detalle.
        let productList = ProductListViewController(viewModel: container.makeProductListViewModel())
        productList.onProductSelected = { [weak self] product in
            self?.showDetail(for: product)
        }
        productsNavigation.setViewControllers([productList], animated: false)
        productsNavigation.tabBarItem = UITabBarItem(
            title: AppStrings.TabBar.products,
            image: UIImage(systemName: AssetNames.Symbol.products),
            selectedImage: nil
        )

        // El menú devuelve el color elegido para aplicarlo al tab bar actual.
        let menuViewModel = container.makeMenuViewModel()
        let menu = MenuViewController(viewModel: menuViewModel)
        menuViewModel.onThemeChanged = { [weak self] theme in
            self?.apply(theme: theme)
        }
        menuNavigation.setViewControllers([menu], animated: false)
        menuNavigation.tabBarItem = UITabBarItem(
            title: AppStrings.TabBar.menu,
            image: UIImage(systemName: AssetNames.Symbol.menu),
            selectedImage: nil
        )

        // Después de tener las dos pestañas, muestro la ventana de la aplicación.
        tabBarController.setViewControllers([productsNavigation, menuNavigation], animated: false)
        apply(theme: container.loadSavedTheme())
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func showDetail(for product: Product) {
        // Reutilizo el navigation de productos para conservar el botón de regreso.
        let detail = ProductDetailViewController(product: product)
        productsNavigation.pushViewController(detail, animated: true)
    }

    /// Aplico el color tanto al appearance nuevo como a las propiedades anteriores de UIKit.
    private func apply(theme: TabBarTheme) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = theme.color
        appearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.7)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        // Esto ayuda a que el fondo también se note con el tab bar nuevo de iOS.
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.barTintColor = theme.color
        tabBarController.tabBar.backgroundColor = theme.color
        tabBarController.tabBar.tintColor = .white
        tabBarController.tabBar.unselectedItemTintColor = .white.withAlphaComponent(0.7)
    }

    private func configureNavigationBars() {
        // Los títulos grandes se usan solamente donde cada pantalla lo permita.
        [productsNavigation, menuNavigation].forEach {
            $0.navigationBar.prefersLargeTitles = true
        }
    }
}
