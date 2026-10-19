//
//  ProductRepository.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Pide los productos a la API y devuelve modelos que entiende la app.
final class ProductRepository: ProductRepositoryProtocol {
    // El cliente queda inyectado para no crear URLSession dentro del repositorio.
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchProducts(offset: Int, limit: Int) async throws -> [Product] {
        // offset indica desde qué producto empezar y limit cuántos pedir.
        let endpoint = Endpoint(
            path: APIConstants.Path.products,
            queryItems: [
                URLQueryItem(name: APIConstants.Query.offset, value: String(offset)),
                URLQueryItem(name: APIConstants.Query.limit, value: String(limit))
            ]
        )
        // La respuesta todavía conserva la estructura que viene del servidor.
        let response: [ProductDTO] = try await apiClient.request(endpoint)

        // compactMap transforma los productos y descarta los que no tienen un título válido.
        return response.compactMap(ProductMapper.map)
    }

    func fetchProductCount() async throws -> Int {
        // Como la API no manda el total, hago una consulta completa solo para contarlos.
        let endpoint = Endpoint(path: APIConstants.Path.products)
        let response: [ProductDTO] = try await apiClient.request(endpoint)

        // Cuento únicamente los productos que realmente podrían verse en el listado.
        return response.compactMap(ProductMapper.map).count
    }
}
