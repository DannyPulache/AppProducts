//
//  Endpoint.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Aquí junto los datos necesarios para armar una petición.
struct Endpoint {
    // La ruta se agrega al dominio base configurado para la API.
    let path: String
    let method: HTTPMethod
    // En este arreglo viajan valores como offset y limit.
    let queryItems: [URLQueryItem]

    init(path: String, method: HTTPMethod = .get, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }

    /// Arma la petición final que después ejecuta el cliente de red.
    func makeURLRequest(baseURL: URL) throws -> URLRequest {
        // Primero uno el dominio con la ruta del endpoint.
        let url = baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        // Si no hay parámetros, dejo queryItems en nil para no agregar un signo ? vacío.
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let finalURL = components.url else { throw NetworkError.invalidURL }

        // El timeout evita que una solicitud se quede esperando para siempre.
        var request = URLRequest(url: finalURL, timeoutInterval: APIConstants.requestTimeout)
        request.httpMethod = method.rawValue
        return request
    }
}
