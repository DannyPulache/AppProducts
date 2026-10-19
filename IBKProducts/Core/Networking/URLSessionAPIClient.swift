//
//  URLSessionAPIClient.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Se encarga de hacer la llamada real a internet y leer el JSON.
final class URLSessionAPIClient: APIClientProtocol {
    // Estas dependencias se reciben por init para poder reemplazarlas en pruebas si hace falta.
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL: URL

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        baseURL: URL = APIConstants.baseURL
    ) {
        self.session = session
        self.decoder = decoder
        self.baseURL = baseURL
    }

    func request<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        // El endpoint solo describe la llamada; aquí se convierte a URLRequest.
        let request = try endpoint.makeURLRequest(baseURL: baseURL)

        do {
            // data contiene el JSON y response trae información como el código HTTP.
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            // Solo considero correctos los códigos del rango 200.
            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.httpStatus(httpResponse.statusCode)
            }

            do {
                // Convierto el JSON al tipo que pidió el repositorio.
                return try decoder.decode(Response.self, from: data)
            } catch {
                throw NetworkError.decoding(error)
            }
        } catch let error as NetworkError {
            // Si ya es un error conocido, lo envío tal como está.
            throw error
        } catch {
            // Los demás errores normalmente vienen de URLSession.
            throw NetworkError.transport(error)
        }
    }
}
