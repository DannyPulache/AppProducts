//
//  FetchProductsUseCase.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Es lo que el ViewModel puede pedir sin saber de red ni de DTOs.
protocol FetchProductsUseCaseProtocol {
    func execute(offset: Int, limit: Int) async throws -> [Product]
    func fetchTotalCount() async throws -> Int
}

/// Deja en un solo lugar las acciones disponibles para consultar productos.
final class FetchProductsUseCase: FetchProductsUseCaseProtocol {
    // El repositorio hace el trabajo de datos; el caso de uso solo dirige la llamada.
    private let repository: ProductRepositoryProtocol

    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }

    func execute(offset: Int, limit: Int) async throws -> [Product] {
        // Paso la paginación tal como la pidió el ViewModel.
        try await repository.fetchProducts(offset: offset, limit: limit)
    }

    func fetchTotalCount() async throws -> Int {
        // Este total permite mostrar textos como "Página 1 de 3".
        try await repository.fetchProductCount()
    }
}
