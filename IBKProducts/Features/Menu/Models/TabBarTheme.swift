//
//  TabBarTheme.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import UIKit

/// Son los colores disponibles para personalizar el tab bar.
enum TabBarTheme: String, CaseIterable, Equatable {
    case blue
    case green
    case orange
    case purple

    // Texto que aparece en la pantalla de menú.
    var displayName: String {
        switch self {
        case .blue: AppStrings.Menu.blue
        case .green: AppStrings.Menu.green
        case .orange: AppStrings.Menu.orange
        case .purple: AppStrings.Menu.purple
        }
    }

    // Color real que se aplica al fondo del tab bar.
    var color: UIColor {
        switch self {
        case .blue: .systemBlue
        case .green: .systemGreen
        case .orange: .systemOrange
        case .purple: .systemPurple
        }
    }
}
