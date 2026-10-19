//
//  ProductListViewController.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import IBKUIComponents
import UIKit

/// Muestra una página de productos y los controles Anterior y Siguiente.
final class ProductListViewController: UIViewController {
    // El ViewModel trae los datos; estas vistas solo se encargan de mostrarlos.
    private let viewModel: ProductListViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let stateView = DSStateView()
    private let paginationView = DSPaginationView()
    private var loadingTask: Task<Void, Never>?

    // El coordinador recibe el producto seleccionado y abre su detalle.
    var onProductSelected: ((Product) -> Void)?

    init(viewModel: ProductListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(DeveloperMessages.coderInitializerUnavailable)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Primero preparo la pantalla, luego conecto eventos y finalmente cargo datos.
        setupView()
        bindViewModel()
        run { await self.viewModel.loadInitial() }
    }

    deinit { loadingTask?.cancel() }

    private func setupView() {
        // Configuración general de la pantalla y la barra de navegación.
        title = AppStrings.ProductList.title
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .always

        // La tabla no usa separadores porque cada producto tiene su propia tarjeta.
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = LayoutConstants.ProductList.estimatedRowHeight
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tableView.register(
            DSTitleTableViewCell.self,
            forCellReuseIdentifier: DSTitleTableViewCell.reuseIdentifier
        )

        // Cada botón dispara la operación correspondiente del ViewModel.
        paginationView.translatesAutoresizingMaskIntoConstraints = false
        paginationView.onPrevious = { [weak self] in
            self?.run { await self?.viewModel.loadPreviousPage() }
        }
        paginationView.onNext = { [weak self] in
            self?.run { await self?.viewModel.loadNextPage() }
        }

        // La paginación queda fija abajo y la tabla ocupa el espacio restante.
        view.addSubview(tableView)
        view.addSubview(paginationView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: paginationView.topAnchor),
            paginationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            paginationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            paginationView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            paginationView.heightAnchor.constraint(equalToConstant: LayoutConstants.ProductList.paginationHeight)
        ])
    }

    /// Escucha los cambios del ViewModel y actualiza solo la parte necesaria.
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in self?.render(state) }
        viewModel.onPaginationChange = { [weak self] in self?.renderPagination() }
        viewModel.onNoMoreProducts = { [weak self] in self?.showEndAlert() }
        renderPagination()
    }

    private func render(_ state: ProductListViewModel.State) {
        // Cada estado tiene una representación clara en pantalla.
        switch state {
        case .idle:
            break
        case .loadingInitial:
            stateView.showLoading(message: AppStrings.ProductList.loading)
            tableView.backgroundView = stateView
        case .loadingPage:
            paginationView.setLoading(true)
        case .loaded:
            tableView.backgroundView = nil
            // Hago un cambio suave para que el salto entre páginas no se sienta brusco.
            UIView.transition(
                with: tableView,
                duration: 0.2,
                options: .transitionCrossDissolve,
                animations: tableView.reloadData
            )
            paginationView.setLoading(false)
        case .empty:
            stateView.showMessage(
                AppStrings.ProductList.empty,
                buttonTitle: AppStrings.ProductList.retry,
                symbolName: "shippingbox",
                action: { [weak self] in self?.run { await self?.viewModel.refresh() } }
            )
            tableView.backgroundView = stateView
            tableView.reloadData()
            paginationView.setLoading(false)
        case let .error(message):
            stateView.showMessage(
                message,
                buttonTitle: AppStrings.ProductList.retry,
                symbolName: "exclamationmark.triangle",
                action: { [weak self] in self?.run { await self?.viewModel.retry() } }
            )
            tableView.backgroundView = stateView
            paginationView.setLoading(false)
        }
    }

    private func renderPagination() {
        // El componente recibe el texto y qué botones puede habilitar.
        paginationView.configure(
            pageText: viewModel.pageDescription,
            canGoPrevious: viewModel.canGoPrevious,
            canGoNext: viewModel.canGoNext
        )
    }

    private func showEndAlert() {
        // Evito presentar dos alertas si el usuario toca rápido varias veces.
        guard presentedViewController == nil else { return }
        let alert = UIAlertController(
            title: AppStrings.ProductList.noMoreTitle,
            message: AppStrings.ProductList.noMoreMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppStrings.Error.accept, style: .default))
        present(alert, animated: true)
    }

    /// Mantiene una sola tarea activa para no mezclar respuestas de varias páginas.
    private func run(_ operation: @escaping @MainActor () async -> Void) {
        loadingTask?.cancel()
        loadingTask = Task { await operation() }
    }
}

extension ProductListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Una fila por cada producto recibido en la página actual.
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // La celda solo recibe el nombre para cumplir con el requisito del listado.
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DSTitleTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? DSTitleTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(title: viewModel.items[indexPath.row].name)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Recupero el producto completo antes de avisar al coordinador.
        tableView.deselectRow(at: indexPath, animated: true)
        guard let product = viewModel.product(at: indexPath.row) else { return }
        onProductSelected?(product)
    }
}
