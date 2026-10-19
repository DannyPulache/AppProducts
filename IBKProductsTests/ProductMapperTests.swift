//
//  ProductMapperTests.swift
//  IBKProductsTests
//
//  Created by DannyPulache on 17/10/26.
//

import XCTest
@testable import IBKProducts

/// Pruebas de la limpieza que se hace antes de usar un producto en la app.
@MainActor
final class ProductMapperTests: XCTestCase {
    func testMapUsesTitleAsDomainNameAndPreservesValues() {
        let dto = ProductDTO(
            id: 7,
            title: "  Laptop  ",
            description: "Fast",
            price: 999,
            images: ["not a url", "ftp://invalid.com/a.png", "https://example.com/a.png"],
            category: .init(name: "Tech")
        )

        let product = ProductMapper.map(dto)

        XCTAssertEqual(product?.id, 7)
        XCTAssertEqual(product?.name, "Laptop")
        XCTAssertEqual(product?.price, 999)
        XCTAssertEqual(product?.imageURL?.absoluteString, "https://example.com/a.png")
        XCTAssertEqual(product?.categoryName, "Tech")
    }

    func testMapRejectsMissingOrEmptyTitle() {
        let missing = ProductDTO(id: 1, title: nil, description: nil, price: nil, images: nil, category: nil)
        let empty = ProductDTO(id: 2, title: "   ", description: nil, price: nil, images: nil, category: nil)

        XCTAssertNil(ProductMapper.map(missing))
        XCTAssertNil(ProductMapper.map(empty))
    }

    func testDecodeMatchesTheRealProductsContract() throws {
        // Este JSON pequeño usa los mismos nombres de campos que devuelve el endpoint.
        let json = """
        {
          "id": 3,
          "title": "Classic Hoodie",
          "price": 69,
          "description": "Soft hoodie",
          "images": ["https://example.com/hoodie.png"],
          "category": { "name": "Clothes" }
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(ProductDTO.self, from: json)
        let product = ProductMapper.map(dto)

        XCTAssertEqual(product?.name, "Classic Hoodie")
        XCTAssertEqual(product?.categoryName, "Clothes")
    }
}
