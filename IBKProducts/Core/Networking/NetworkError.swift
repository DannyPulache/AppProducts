//
//  NetworkError.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Errores que puedo recibir mientras consulto la API.
enum NetworkError: Error {
    // La URL no se pudo construir correctamente.
    case invalidURL
    // La respuesta recibida no era una respuesta HTTP.
    case invalidResponse
    // El servidor respondió, pero con un código distinto de 2xx.
    case httpStatus(Int)
    // Llegó información, pero no se pudo convertir al modelo esperado.
    case decoding(Error)
    // Falló la conexión, por ejemplo por falta de internet.
    case transport(Error)
}

extension NetworkError: LocalizedError {
    /// Dejo un texto corto para entender más rápido qué salió mal.
    var errorDescription: String? {
        switch self {
        case .invalidURL: "La URL de la solicitud no es válida."
        case .invalidResponse: "La respuesta del servidor no es válida."
        case let .httpStatus(code): "El servidor devolvió el estado HTTP \(code)."
        case .decoding: "La respuesta no coincide con el contrato esperado."
        case .transport: "No fue posible comunicarse con el servidor."
        }
    }
}
