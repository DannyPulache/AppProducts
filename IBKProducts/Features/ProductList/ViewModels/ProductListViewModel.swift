//
//  ProductListViewModel.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Aquí queda la lógica del listado y de los botones de paginación.
@MainActor
final class ProductListViewModel {
    // La vista usa estos estados para saber qué debe mostrar.
    enum State: Equatable {
        // Todavía no se hizo ninguna carga.
        case idle
        // Se está trayendo la primera página.
        case loadingInitial
        // Se está cambiando o actualizando una página.
        case loadingPage
        case loaded
        case empty
        case error(String)
    }

    // Recuerdo qué operación falló para que el botón Reintentar haga lo correcto.
    private enum RetryAction {
        case initial
        case page(Int)
        case refresh
    }

    // Dependencias y valores internos que no necesita conocer la vista.
    private let fetchProductsUseCase: FetchProductsUseCaseProtocol
    private let pageSize: Int
    private var products: [Product] = []
    private var isLoading = false
    private var reachedEnd = false
    private var retryAction: RetryAction = .initial

    // La vista puede leer estos datos, pero solo el ViewModel los modifica.
    private(set) var items: [ProductListItemViewData] = []
    private(set) var currentPage = 1
    private(set) var totalPages = 1
    private(set) var state: State = .idle {
        didSet { onStateChange?(state) }
    }

    // Estos closures avisan cambios sin hacer que el ViewModel importe UIKit.
    var onStateChange: ((State) -> Void)?
    var onPaginationChange: (() -> Void)?
    var onNoMoreProducts: (() -> Void)?

    // Mientras carga, bloqueo ambos botones para evitar llamadas repetidas.
    var canGoPrevious: Bool { !isLoading && currentPage > 1 }
    var canGoNext: Bool { !isLoading && !reachedEnd }
    var pageDescription: String {
        String(format: AppStrings.ProductList.page, currentPage, totalPages)
    }

    init(
        fetchProductsUseCase: FetchProductsUseCaseProtocol,
        pageSize: Int = LayoutConstants.ProductList.pageSize
    ) {
        self.fetchProductsUseCase = fetchProductsUseCase
        self.pageSize = pageSize
    }

    /// Al entrar, primero calculo el total y luego cargo la página uno.
    func loadInitial() async {
        guard state == .idle else { return }
        await loadCountAndPage(targetPage: 1, loadingState: .loadingInitial, retry: .initial)
    }

    /// Avanza una página. Si ya llegué al final, solo muestro el aviso.
    func loadNextPage() async {
        guard canGoNext else {
            if reachedEnd { onNoMoreProducts?() }
            return
        }
        await loadPage(currentPage + 1, retry: .page(currentPage + 1))
    }

    /// Regresa una página y vuelve a permitir que se avance.
    func loadPreviousPage() async {
        guard canGoPrevious else { return }
        reachedEnd = false
        await loadPage(currentPage - 1, retry: .page(currentPage - 1))
    }

    /// Vuelve a contar los productos y recarga la página que siga siendo válida.
    func refresh() async {
        await loadCountAndPage(targetPage: currentPage, loadingState: .loadingPage, retry: .refresh)
    }

    /// Repite la última operación que falló.
    func retry() async {
        switch retryAction {
        case .initial:
            await loadCountAndPage(targetPage: 1, loadingState: .loadingInitial, retry: .initial)
        case let .page(page):
            await loadPage(page, retry: .page(page))
        case .refresh:
            await loadCountAndPage(targetPage: currentPage, loadingState: .loadingPage, retry: .refresh)
        }
    }

    func product(at index: Int) -> Product? {
        // La pantalla de detalle necesita el modelo completo, no solo el nombre de la celda.
        guard products.indices.contains(index) else { return nil }
        return products[index]
    }

    /// Consulta cuántos productos hay para calcular las páginas de 20.
    private func loadCountAndPage(
        targetPage: Int,
        loadingState: State,
        retry: RetryAction
    ) async {
        // No dejo que otra carga empiece mientras hay una en curso.
        guard !isLoading else { return }
        isLoading = true
        state = loadingState
        onPaginationChange?()

        do {
            let totalProducts = try await fetchProductsUseCase.fetchTotalCount()
            // ceil redondea hacia arriba: 41 productos necesitan 3 páginas.
            totalPages = max(1, Int(ceil(Double(totalProducts) / Double(pageSize))))
            // Si el total bajó, evito pedir una página que ya no existe.
            let validPage = min(max(1, targetPage), totalPages)
            isLoading = false
            reachedEnd = false
            await loadPage(validPage, retry: retry)
        } catch {
            isLoading = false
            retryAction = retry
            state = .error(AppStrings.Error.generic)
            onPaginationChange?()
        }
    }

    /// Calcula el offset y reemplaza lo que se ve con la página solicitada.
    private func loadPage(_ page: Int, retry: RetryAction) async {
        guard !isLoading else { return }
        isLoading = true
        retryAction = retry
        state = products.isEmpty && page == 1 ? .loadingInitial : .loadingPage
        onPaginationChange?()

        do {
            // Ejemplo: para la página 2, (2 - 1) * 20 da offset 20.
            let offset = (page - 1) * pageSize
            let response = try await fetchProductsUseCase.execute(offset: offset, limit: pageSize)
            isLoading = false

            // Si al avanzar llega vacío, conservo la página anterior y marco el final.
            if response.isEmpty, page > currentPage {
                reachedEnd = true
                onNoMoreProducts?()
                state = products.isEmpty ? .empty : .loaded
                onPaginationChange?()
                return
            }

            // Guardo el modelo completo para abrir el detalle y preparo nombres para las celdas.
            products = response
            items = response.map { ProductListItemViewData(name: $0.name) }
            currentPage = page
            totalPages = max(totalPages, page)
            state = items.isEmpty ? .empty : .loaded
            onPaginationChange?()
        } catch {
            // El texto técnico no se muestra al usuario; la vista recibe un mensaje simple.
            isLoading = false
            state = .error(AppStrings.Error.generic)
            onPaginationChange?()
        }
    }
}
