//
//  ProductMapper.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Limpia la respuesta de la API antes de usarla en la aplicación.
enum ProductMapper {
    static func map(_ dto: ProductDTO) -> Product? {
        // El endpoint llama `title` al nombre. También quito espacios al inicio y al final.
        guard let rawName = dto.title?.trimmingCharacters(in: .whitespacesAndNewlines),
              !rawName.isEmpty else {
            // Si no tiene un título útil, no lo agrego al listado.
            return nil
        }

        // Me quedo con la primera imagen que tenga una dirección web válida.
        let imageURL = dto.images?
            .compactMap(URL.init(string:))
            .first { $0.scheme == "http" || $0.scheme == "https" }

        // Desde aquí el resto de la app trabaja con valores seguros, no con opcionales.
        return Product(
            id: dto.id ?? 0,
            name: rawName,
            description: dto.description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            price: dto.price ?? 0,
            imageURL: imageURL,
            categoryName: dto.category?.name ?? AppStrings.ProductDetail.unknownCategory
        )
    }
}
