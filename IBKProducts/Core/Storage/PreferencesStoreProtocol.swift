//
//  PreferencesStoreProtocol.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Son las operaciones pequeñas que necesito para guardar preferencias.
protocol PreferencesStoreProtocol {
    // Al usar un protocolo no amarro el repositorio directamente a UserDefaults.
    func string(forKey key: String) -> String?
    func set(_ value: String, forKey key: String)
}
