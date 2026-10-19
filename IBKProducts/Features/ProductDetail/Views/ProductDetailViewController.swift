//
//  ProductDetailViewController.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import IBKUIComponents
import UIKit

/// Muestra la información del producto que se tocó en el listado.
final class ProductDetailViewController: UIViewController {
    // Recibo el producto ya listo para mostrar y un formateador para el precio.
    private let product: Product
    private let currencyFormatter: CurrencyFormatter
    private let remoteImageView = DSRemoteImageView()

    init(product: Product, currencyFormatter: CurrencyFormatter = CurrencyFormatter()) {
        self.product = product
        self.currencyFormatter = currencyFormatter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError(DeveloperMessages.coderInitializerUnavailable)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // La interfaz se arma primero y la imagen puede terminar de cargar después.
        setupView()
        remoteImageView.load(url: product.imageURL)
    }

    // Si se cierra la pantalla, ya no hace falta continuar una descarga pendiente.
    deinit { remoteImageView.cancelImageLoad() }

    private func setupView() {
        // El scroll permite que descripciones largas entren en pantallas pequeñas.
        title = AppStrings.ProductDetail.title
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        let scrollView = UIScrollView()
        let contentView = UIView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset.bottom = 24

        // La imagen va en su propia tarjeta para separarla del texto.
        let imageCard = makeCardView()
        remoteImageView.translatesAutoresizingMaskIntoConstraints = false
        remoteImageView.contentMode = .scaleAspectFit
        remoteImageView.backgroundColor = .tertiarySystemGroupedBackground
        remoteImageView.layer.cornerRadius = 16
        remoteImageView.layer.cornerCurve = .continuous
        remoteImageView.clipsToBounds = true
        imageCard.addSubview(remoteImageView)

        // En esta tarjeta agrupo nombre, categoría y precio.
        let nameLabel = makeLabel(text: product.name, style: .title2, weight: .bold)
        let priceLabel = makeLabel(
            text: currencyFormatter.string(from: product.price),
            style: .title2,
            weight: .bold,
            color: .systemGreen
        )
        let categoryBadge = makeCategoryBadge(text: product.categoryName)
        let priceCaption = makeLabel(
            text: AppStrings.ProductDetail.price.uppercased(),
            style: .caption1,
            weight: .semibold,
            color: .secondaryLabel
        )
        let priceStack = UIStackView(arrangedSubviews: [priceCaption, priceLabel])
        priceStack.axis = .vertical
        priceStack.spacing = 4

        let summaryStack = UIStackView(arrangedSubviews: [nameLabel, categoryBadge, priceStack])
        summaryStack.axis = .vertical
        summaryStack.alignment = .leading
        summaryStack.spacing = 14
        let summaryCard = makeCard(containing: summaryStack)

        // La descripción queda aparte porque puede ocupar varias líneas.
        let descriptionTitle = makeLabel(
            text: AppStrings.ProductDetail.description,
            style: .headline,
            weight: .semibold
        )
        let description = product.description.isEmpty
            ? AppStrings.ProductDetail.missingDescription
            : product.description
        let descriptionLabel = makeLabel(text: description, style: .body, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let descriptionStack = UIStackView(arrangedSubviews: [descriptionTitle, descriptionLabel])
        descriptionStack.axis = .vertical
        descriptionStack.spacing = 10
        let descriptionCard = makeCard(containing: descriptionStack)

        // El stack mantiene las tres tarjetas ordenadas una debajo de otra.
        let stack = UIStackView(arrangedSubviews: [imageCard, summaryCard, descriptionCard])
        stack.axis = .vertical
        stack.spacing = LayoutConstants.ProductDetail.sectionSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stack)

        // Todas las medidas repetidas salen de LayoutConstants.
        let inset = LayoutConstants.ProductDetail.contentInset
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            imageCard.heightAnchor.constraint(
                equalToConstant: LayoutConstants.ProductDetail.imageHeight + 20
            ),
            remoteImageView.topAnchor.constraint(equalTo: imageCard.topAnchor, constant: 10),
            remoteImageView.leadingAnchor.constraint(equalTo: imageCard.leadingAnchor, constant: 10),
            remoteImageView.trailingAnchor.constraint(equalTo: imageCard.trailingAnchor, constant: -10),
            remoteImageView.bottomAnchor.constraint(equalTo: imageCard.bottomAnchor, constant: -10)
        ])
    }

    /// Crea la base visual que comparten las tarjetas.
    private func makeCardView() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = LayoutConstants.ProductDetail.cardCornerRadius
        card.layer.cornerCurve = .continuous
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 5)
        return card
    }

    /// Mete un stack dentro de una tarjeta dejando el mismo espacio alrededor.
    private func makeCard(containing stack: UIStackView) -> UIView {
        let card = makeCardView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        let inset = LayoutConstants.ProductDetail.cardInset
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: inset),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: inset),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -inset),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -inset)
        ])
        return card
    }

    /// Arma la etiqueta azul donde se ve la categoría.
    private func makeCategoryBadge(text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        container.layer.cornerRadius = 10
        container.layer.cornerCurve = .continuous

        let label = makeLabel(
            text: text,
            style: .subheadline,
            weight: .semibold,
            color: .systemBlue
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 7),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -7)
        ])
        return container
    }

    /// Crea labels con el mismo soporte de varias líneas y tamaño de texto.
    private func makeLabel(
        text: String,
        style: UIFont.TextStyle,
        weight: UIFont.Weight,
        color: UIColor = .label
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: style).pointSize, weight: weight)
        label.textColor = color
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }
}
