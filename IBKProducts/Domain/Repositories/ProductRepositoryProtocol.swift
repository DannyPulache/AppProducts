//
//  ProductRepositoryProtocol.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Indica qué consultas de productos puede pedir el caso de uso.
protocol ProductRepositoryProtocol {
    // Devuelve una parte del catálogo usando la paginación del endpoint.
    func fetchProducts(offset: Int, limit: Int) async throws -> [Product]
    // Se usa para calcular cuántas páginas debe mostrar la barra inferior.
    func fetchProductCount() async throws -> Int
}
