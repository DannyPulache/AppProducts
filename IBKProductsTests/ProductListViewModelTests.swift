//
//  ProductListViewModelTests.swift
//  IBKProductsTests
//
//  Created by DannyPulache on 17/10/26.
//

import XCTest
@testable import IBKProducts

/// Pruebas de la carga, los errores y la paginación manual del listado.
@MainActor
final class ProductListViewModelTests: XCTestCase {
    func testDefaultPaginationRequestsTwentyProductsAndCalculatesTotalPages() async {
        let useCase = FetchProductsUseCaseMock(countResults: [.success(45)], pageResults: [.success([makeProduct(1)])])
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)

        await sut.loadInitial()

        XCTAssertEqual(useCase.requests, [.init(offset: 0, limit: 20)])
        XCTAssertEqual(sut.currentPage, 1)
        XCTAssertEqual(sut.totalPages, 3)
        XCTAssertEqual(sut.pageDescription, "Página 1 de 3")
    }

    func testNextPageUsesExpectedOffsetAndReplacesVisibleItems() async {
        let useCase = FetchProductsUseCaseMock(
            countResults: [.success(60)],
            pageResults: [.success([makeProduct(1)]), .success([makeProduct(21)])]
        )
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)

        await sut.loadInitial()
        await sut.loadNextPage()

        XCTAssertEqual(useCase.requests.last, .init(offset: 20, limit: 20))
        XCTAssertEqual(sut.items, [.init(name: "Product 21")])
        XCTAssertEqual(sut.currentPage, 2)
    }

    func testPreviousPageReturnsToPriorOffset() async {
        let useCase = FetchProductsUseCaseMock(
            countResults: [.success(60)],
            pageResults: [.success([makeProduct(1)]), .success([makeProduct(21)]), .success([makeProduct(1)])]
        )
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)

        await sut.loadInitial()
        await sut.loadNextPage()
        await sut.loadPreviousPage()

        XCTAssertEqual(useCase.requests.last, .init(offset: 0, limit: 20))
        XCTAssertEqual(sut.currentPage, 1)
    }

    func testEmptyForwardPageKeepsLastPageAndStopsFutureRequests() async {
        let useCase = FetchProductsUseCaseMock(
            countResults: [.success(40)],
            pageResults: [.success([makeProduct(1)]), .success([])]
        )
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)
        var endMessageCount = 0
        sut.onNoMoreProducts = { endMessageCount += 1 }

        await sut.loadInitial()
        await sut.loadNextPage()
        await sut.loadNextPage()

        XCTAssertEqual(sut.currentPage, 1)
        XCTAssertEqual(useCase.requests.count, 2)
        XCTAssertEqual(endMessageCount, 2)
        XCTAssertFalse(sut.canGoNext)
    }

    func testZeroCountStillChecksFirstPageAndPublishesEmptyWhenServerReturnsNothing() async {
        let useCase = FetchProductsUseCaseMock(countResults: [.success(0)], pageResults: [.success([])])
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)

        await sut.loadInitial()

        XCTAssertEqual(useCase.requests, [.init(offset: 0, limit: 20)])
        XCTAssertEqual(sut.totalPages, 1)
        XCTAssertEqual(sut.state, .empty)
    }

    func testNextPageCanAdvanceBeyondInitiallyCalculatedTotal() async {
        let useCase = FetchProductsUseCaseMock(
            countResults: [.success(20)],
            pageResults: [.success([makeProduct(1)]), .success([makeProduct(21)])]
        )
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)

        await sut.loadInitial()
        await sut.loadNextPage()

        XCTAssertEqual(sut.currentPage, 2)
        XCTAssertEqual(sut.totalPages, 2)
    }

    func testCountFailurePublishesErrorAndRetryRecovers() async {
        let useCase = FetchProductsUseCaseMock(
            countResults: [.failure(TestError.expected), .success(20)],
            pageResults: [.success([makeProduct(1)])]
        )
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)

        await sut.loadInitial()
        XCTAssertEqual(sut.state, .error(AppStrings.Error.generic))
        await sut.retry()

        XCTAssertEqual(useCase.countRequestCount, 2)
        XCTAssertEqual(sut.state, .loaded)
    }

    func testRetryAfterPageFailureRequestsTheSamePage() async {
        let useCase = FetchProductsUseCaseMock(
            countResults: [.success(40)],
            pageResults: [.success([makeProduct(1)]), .failure(TestError.expected), .success([makeProduct(21)])]
        )
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)

        await sut.loadInitial()
        await sut.loadNextPage()
        await sut.retry()

        XCTAssertEqual(useCase.requests.map(\.offset), [0, 20, 20])
        XCTAssertEqual(sut.currentPage, 2)
    }

    func testRefreshRecountsAndClampsADeletedLastPage() async {
        let useCase = FetchProductsUseCaseMock(
            countResults: [.success(40), .success(10)],
            pageResults: [.success([makeProduct(1)]), .success([makeProduct(21)]), .success([makeProduct(1)])]
        )
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)

        await sut.loadInitial()
        await sut.loadNextPage()
        await sut.refresh()

        XCTAssertEqual(sut.currentPage, 1)
        XCTAssertEqual(sut.totalPages, 1)
        XCTAssertEqual(useCase.requests.last?.offset, 0)
    }

    func testRetryAfterRefreshCountFailureRecountsBeforeLoadingProducts() async {
        let useCase = FetchProductsUseCaseMock(
            countResults: [.success(20), .failure(TestError.expected), .success(20)],
            pageResults: [.success([makeProduct(1)]), .success([makeProduct(2)])]
        )
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)

        await sut.loadInitial()
        await sut.refresh()
        await sut.retry()

        XCTAssertEqual(useCase.countRequestCount, 3)
        XCTAssertEqual(useCase.requests.count, 2)
        XCTAssertEqual(sut.items.first?.name, "Product 2")
    }

    func testProductReturnsNilForAnInvalidIndex() async {
        let useCase = FetchProductsUseCaseMock(countResults: [.success(1)], pageResults: [.success([makeProduct(1)])])
        let sut = ProductListViewModel(fetchProductsUseCase: useCase)

        await sut.loadInitial()

        XCTAssertNil(sut.product(at: -1))
        XCTAssertNil(sut.product(at: 1))
        XCTAssertEqual(sut.product(at: 0)?.id, 1)
    }
}

private extension ProductListViewModelTests {
    // Error sencillo que uso para simular fallas de red.
    enum TestError: Error { case expected }

    // Guardo offset y limit para revisar qué página pidió el ViewModel.
    struct Request: Equatable {
        let offset: Int
        let limit: Int
    }

    final class FetchProductsUseCaseMock: FetchProductsUseCaseProtocol {
        // Cada arreglo entrega sus resultados en el mismo orden de las llamadas.
        private var countResults: [Result<Int, Error>]
        private var pageResults: [Result<[Product], Error>]
        private(set) var requests: [Request] = []
        private(set) var countRequestCount = 0

        init(countResults: [Result<Int, Error>], pageResults: [Result<[Product], Error>]) {
            self.countResults = countResults
            self.pageResults = pageResults
        }

        func execute(offset: Int, limit: Int) async throws -> [Product] {
            // Registro la petición antes de devolver el resultado preparado por el test.
            requests.append(Request(offset: offset, limit: limit))
            return try pageResults.removeFirst().get()
        }

        func fetchTotalCount() async throws -> Int {
            // Este contador permite comprobar si un reintento volvió a consultar el total.
            countRequestCount += 1
            return try countResults.removeFirst().get()
        }
    }

    func makeProduct(_ id: Int) -> Product {
        // Crea un producto mínimo para no repetir los mismos datos en cada prueba.
        Product(
            id: id,
            name: "Product \(id)",
            description: "Description",
            price: 10,
            imageURL: nil,
            categoryName: "Category"
        )
    }
}
