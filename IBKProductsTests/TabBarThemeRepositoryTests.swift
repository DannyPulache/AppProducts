//
//  TabBarThemeRepositoryTests.swift
//  IBKProductsTests
//
//  Created by DannyPulache on 17/10/26.
//

import XCTest
@testable import IBKProducts

/// Pruebas para leer, guardar y recuperar el color del tab bar.
final class TabBarThemeRepositoryTests: XCTestCase {
    func testNoSavedValueReturnsBlue() {
        let sut = UserDefaultsTabBarThemeRepository(store: PreferencesStoreMock())
        XCTAssertEqual(sut.loadTheme(), .blue)
    }

    func testSaveAndLoadUsesRawValue() {
        let store = PreferencesStoreMock()
        let sut = UserDefaultsTabBarThemeRepository(store: store)

        sut.saveTheme(.purple)

        XCTAssertEqual(store.value, "purple")
        XCTAssertEqual(sut.loadTheme(), .purple)
    }

    func testUnknownSavedValueReturnsBlue() {
        let store = PreferencesStoreMock(value: "unknown")
        let sut = UserDefaultsTabBarThemeRepository(store: store)
        XCTAssertEqual(sut.loadTheme(), .blue)
    }
}

private final class PreferencesStoreMock: PreferencesStoreProtocol {
    // Reemplaza UserDefaults por una sola variable durante la prueba.
    var value: String?
    init(value: String? = nil) { self.value = value }
    func string(forKey key: String) -> String? { value }
    func set(_ value: String, forKey key: String) { self.value = value }
}
