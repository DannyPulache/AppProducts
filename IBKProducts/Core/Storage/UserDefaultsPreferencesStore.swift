//
//  UserDefaultsPreferencesStore.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Guarda y lee valores simples usando UserDefaults.
final class UserDefaultsPreferencesStore: PreferencesStoreProtocol {
    // Se puede pasar otro UserDefaults para que las pruebas no usen el almacenamiento real.
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func string(forKey key: String) -> String? {
        // Devuelve nil cuando todavía no existe un valor guardado.
        userDefaults.string(forKey: key)
    }

    func set(_ value: String, forKey key: String) {
        // UserDefaults se encarga de conservar este dato entre aperturas de la app.
        userDefaults.set(value, forKey: key)
    }
}
