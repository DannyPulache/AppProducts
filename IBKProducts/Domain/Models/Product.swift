//
//  Product.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Es el producto que usa la app después de limpiar la respuesta de la API.
struct Product: Equatable {
    // Aquí ya no hay opcionales innecesarios, así la vista recibe datos fáciles de usar.
    let id: Int
    let name: String
    let description: String
    let price: Double
    let imageURL: URL?
    let categoryName: String
}
