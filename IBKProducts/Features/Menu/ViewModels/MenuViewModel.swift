//
//  MenuViewModel.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Maneja las opciones de color y la selección actual del menú.
@MainActor
final class MenuViewModel {
    // El repositorio lee y guarda la preferencia.
    private let repository: TabBarThemeRepositoryProtocol

    // allCases evita tener que repetir manualmente la lista de colores.
    let themes = TabBarTheme.allCases
    private(set) var selectedTheme: TabBarTheme
    // El coordinador escucha este cierre para cambiar el tab bar en el momento.
    var onThemeChanged: ((TabBarTheme) -> Void)?

    init(repository: TabBarThemeRepositoryProtocol) {
        self.repository = repository
        selectedTheme = repository.loadTheme()
    }

    func selectTheme(at index: Int) {
        // Evito un crash si por alguna razón llega una posición que no existe.
        guard themes.indices.contains(index) else { return }
        let theme = themes[index]
        // Actualizo memoria, guardo la preferencia y aviso a la pantalla principal.
        selectedTheme = theme
        repository.saveTheme(theme)
        onThemeChanged?(theme)
    }
}
