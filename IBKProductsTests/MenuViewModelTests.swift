//
//  MenuViewModelTests.swift
//  IBKProductsTests
//
//  Created by DannyPulache on 17/10/26.
//

import XCTest
@testable import IBKProducts

/// Pruebas del color guardado y de la selección del menú.
@MainActor
final class MenuViewModelTests: XCTestCase {
    func testInitializationRestoresSavedTheme() {
        let repository = ThemeRepositoryMock(savedTheme: .purple)
        let sut = MenuViewModel(repository: repository)

        XCTAssertEqual(sut.selectedTheme, .purple)
    }

    func testSelectingThemePersistsAndNotifies() {
        let repository = ThemeRepositoryMock(savedTheme: .blue)
        let sut = MenuViewModel(repository: repository)
        var notifiedTheme: TabBarTheme?
        sut.onThemeChanged = { notifiedTheme = $0 }

        sut.selectTheme(at: 2)

        XCTAssertEqual(repository.savedTheme, .orange)
        XCTAssertEqual(notifiedTheme, .orange)
    }

    func testInvalidIndexDoesNothing() {
        let repository = ThemeRepositoryMock(savedTheme: .green)
        let sut = MenuViewModel(repository: repository)

        sut.selectTheme(at: 99)

        XCTAssertEqual(sut.selectedTheme, .green)
        XCTAssertEqual(repository.saveCount, 0)
    }
}

private final class ThemeRepositoryMock: TabBarThemeRepositoryProtocol {
    // Este mock guarda todo en memoria para no usar UserDefaults en los tests.
    var savedTheme: TabBarTheme
    private(set) var saveCount = 0

    init(savedTheme: TabBarTheme) { self.savedTheme = savedTheme }
    func loadTheme() -> TabBarTheme { savedTheme }
    func saveTheme(_ theme: TabBarTheme) {
        // También cuento las llamadas para saber si un índice inválido intentó guardar algo.
        savedTheme = theme
        saveCount += 1
    }
}
