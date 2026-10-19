//
//  AppContainer.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Aquí creo las dependencias principales para no armarlas dentro de cada pantalla.
@MainActor
final class AppContainer {
    // Se comparten porque no necesitan crearse otra vez cada vez que cambia una pantalla.
    private let fetchProductsUseCase: FetchProductsUseCaseProtocol
    private let themeRepository: TabBarThemeRepositoryProtocol

    init() {
        // Primero conecto la parte de red con el repositorio y el caso de uso.
        let apiClient = URLSessionAPIClient()
        let productRepository = ProductRepository(apiClient: apiClient)
        fetchProductsUseCase = FetchProductsUseCase(repository: productRepository)

        // Las preferencias se guardan aparte porque no dependen de la API.
        let preferencesStore = UserDefaultsPreferencesStore()
        themeRepository = UserDefaultsTabBarThemeRepository(store: preferencesStore)
    }

    /// Creo un ViewModel nuevo cuando se va a mostrar el listado.
    func makeProductListViewModel() -> ProductListViewModel {
        ProductListViewModel(fetchProductsUseCase: fetchProductsUseCase)
    }

    /// El menú usa el mismo repositorio para leer el último color guardado.
    func makeMenuViewModel() -> MenuViewModel {
        MenuViewModel(repository: themeRepository)
    }

    /// Leo el tema al iniciar para que el tab bar no vuelva siempre al color inicial.
    func loadSavedTheme() -> TabBarTheme {
        themeRepository.loadTheme()
    }
}
