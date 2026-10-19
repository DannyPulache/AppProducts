//
//  DSTitleTableViewCell.swift
//  IBKUIComponents
//
//  Created by DannyPulache on 17/10/26.
//

import UIKit

/// Celda del listado. Solo muestra el nombre como pide el requisito.
public final class DSTitleTableViewCell: UITableViewCell {
    // Este identificador permite reutilizar la celda al hacer scroll.
    public static let reuseIdentifier = "DSTitleTableViewCell"

    // Mantengo las medidas de la celda juntas para que sea fácil ajustar su espacio.
    private enum Layout {
        static let cardVerticalMargin: CGFloat = 6
        static let cardHorizontalMargin: CGFloat = 16
        static let minimumCardHeight: CGFloat = 72
        static let contentPadding: CGFloat = 14
        static let iconSize: CGFloat = 44
        static let iconImageSize: CGFloat = 22
    }

    // La tarjeta, el ícono y la flecha forman la apariencia de cada fila.
    private let cardView = UIView()
    private let iconContainerView = UIView()
    private let productImageView = UIImageView(image: UIImage(systemName: "shippingbox.fill"))
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Coloca el nombre y deja la misma información disponible para VoiceOver.
    public func configure(title: String) {
        titleLabel.text = title
        accessibilityLabel = title
        accessibilityTraits = .button
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        // Limpio el contenido antes de usar la celda con otro producto.
        titleLabel.text = nil
        accessibilityLabel = nil
    }

    /// Reduce un poco la tarjeta al tocarla para que se sienta la selección.
    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.18) {
            self.cardView.transform = highlighted
                ? CGAffineTransform(scaleX: 0.98, y: 0.98)
                : .identity
            self.cardView.alpha = highlighted ? 0.82 : 1
        }
    }

    private func setupView() {
        // La celda es transparente porque el fondo visible lo dibuja cardView.
        backgroundColor = .clear
        selectionStyle = .none

        // Sombra suave y esquinas redondas para separar cada producto.
        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 18
        cardView.layer.cornerCurve = .continuous
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.07
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)

        // El ícono es decorativo; el único dato real del listado sigue siendo el nombre.
        iconContainerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        iconContainerView.layer.cornerRadius = 14
        iconContainerView.layer.cornerCurve = .continuous

        productImageView.tintColor = .systemBlue
        productImageView.contentMode = .scaleAspectFit
        productImageView.isAccessibilityElement = false

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true

        chevronImageView.tintColor = .tertiaryLabel
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.isAccessibilityElement = false

        // Desactivo las restricciones automáticas antes de usar Auto Layout.
        [cardView, iconContainerView, productImageView, titleLabel, chevronImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        contentView.addSubview(cardView)
        cardView.addSubview(iconContainerView)
        iconContainerView.addSubview(productImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            // La altura mínima evita que una fila de texto corto aplaste el padding del ícono.
            cardView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Layout.cardVerticalMargin
            ),
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Layout.cardHorizontalMargin
            ),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Layout.cardHorizontalMargin
            ),
            cardView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Layout.cardVerticalMargin
            ),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.minimumCardHeight),

            // El ícono queda centrado y con aire alrededor incluso cuando el título ocupa una línea.
            iconContainerView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Layout.contentPadding
            ),
            iconContainerView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            iconContainerView.heightAnchor.constraint(equalTo: iconContainerView.widthAnchor),
            productImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            productImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: Layout.iconImageSize),
            productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor),

            // El texto conserva el mismo padding aunque crezca a dos líneas.
            titleLabel.topAnchor.constraint(
                greaterThanOrEqualTo: cardView.topAnchor,
                constant: Layout.contentPadding
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: iconContainerView.trailingAnchor,
                constant: Layout.contentPadding
            ),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: cardView.bottomAnchor,
                constant: -Layout.contentPadding
            ),
            titleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
