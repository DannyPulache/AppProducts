//
//  ProductDTO.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Este modelo tiene la misma forma que el JSON de productos.
struct ProductDTO: Decodable {
    // Los campos son opcionales porque la API pública puede devolver datos incompletos.
    let id: Int?
    let title: String?
    let description: String?
    let price: Double?
    let images: [String]?
    let category: CategoryDTO?

    // De la categoría solo necesito el nombre para mostrarlo en el detalle.
    struct CategoryDTO: Decodable {
        let name: String?
    }

    // Estas claves indican qué campos voy a leer del JSON.
    private enum CodingKeys: String, CodingKey {
        case id, title, description, price, images, category
    }

    /// Intento leer cada campo por separado para que uno malo no rompa todo el listado.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        title = try? container.decodeIfPresent(String.self, forKey: .title)
        description = try? container.decodeIfPresent(String.self, forKey: .description)
        price = try? container.decodeIfPresent(Double.self, forKey: .price)
        images = try? container.decodeIfPresent([String].self, forKey: .images)
        category = try? container.decodeIfPresent(CategoryDTO.self, forKey: .category)
    }

    /// Este init me deja crear respuestas pequeñas y controladas en los tests.
    init(
        id: Int?,
        title: String?,
        description: String?,
        price: Double?,
        images: [String]?,
        category: CategoryDTO?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.images = images
        self.category = category
    }
}
