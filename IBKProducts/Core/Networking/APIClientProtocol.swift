//
//  APIClientProtocol.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Lo uso para que las demás capas puedan pedir datos sin conocer URLSession.
protocol APIClientProtocol {
    // El tipo de respuesta se decide en cada llamada y debe poder leer JSON.
    func request<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response
}
