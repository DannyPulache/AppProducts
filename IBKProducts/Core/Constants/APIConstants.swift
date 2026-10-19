//
//  APIConstants.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Aquí dejo las rutas y parámetros que se repiten al llamar a la API.
enum APIConstants {
    // Si la URL cambia, solo tendría que modificarla en este archivo.
    static let baseURL = URL(string: "https://api.escuelajs.co/api/v1/")!
    static let requestTimeout: TimeInterval = 30

    enum Path {
        // Ruta usada para obtener todos los productos y también las páginas.
        static let products = "products"
    }

    enum Query {
        // offset indica desde dónde empezar y limit cuántos registros pedir.
        static let offset = "offset"
        static let limit = "limit"
    }
}

/// Valor usado para mostrar todos los precios con la misma moneda.
enum FormattingConstants {
    static let currencyCode = "USD"
}
