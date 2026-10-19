//
//  UserDefaultsTabBarThemeRepository.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Conserva el color elegido aunque la app se cierre.
final class UserDefaultsTabBarThemeRepository: TabBarThemeRepositoryProtocol {
    // Uso esta abstracción para poder probar el repositorio sin tocar preferencias reales.
    private let store: PreferencesStoreProtocol

    init(store: PreferencesStoreProtocol) {
        self.store = store
    }

    func loadTheme() -> TabBarTheme {
        // Si no hay un valor guardado o ya no existe, uso azul como opción inicial.
        guard let value = store.string(forKey: StorageKeys.selectedTabBarTheme),
              let theme = TabBarTheme(rawValue: value) else {
            return .blue
        }
        return theme
    }

    func saveTheme(_ theme: TabBarTheme) {
        // Guardo el rawValue porque UserDefaults trabaja bien con String.
        store.set(theme.rawValue, forKey: StorageKeys.selectedTabBarTheme)
    }
}
