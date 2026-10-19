//
//  TabBarThemeRepositoryProtocol.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Permite leer y guardar el color sin que el ViewModel conozca UserDefaults.
protocol TabBarThemeRepositoryProtocol {
    // Si ya existe una elección, la recupera al abrir la app.
    func loadTheme() -> TabBarTheme
    // Guarda el nuevo color elegido por el usuario.
    func saveTheme(_ theme: TabBarTheme)
}
