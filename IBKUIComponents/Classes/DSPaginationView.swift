//
//  DSPaginationView.swift
//  IBKUIComponents
//
//  Created by DannyPulache on 17/10/26.
//

import UIKit

/// Barra inferior con los botones para cambiar de página manualmente.
public final class DSPaginationView: UIView {
    // Estas vistas se crean una sola vez y luego solo actualizo su estado.
    private let previousButton = UIButton(type: .system)
    private let pageLabel = UILabel()
    private let nextButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // La pantalla asigna qué hacer cuando se toca cada botón.
    public var onPrevious: (() -> Void)?
    public var onNext: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Cambia el número de página y habilita los botones que se pueden usar.
    public func configure(pageText: String, canGoPrevious: Bool, canGoNext: Bool) {
        pageLabel.text = pageText
        previousButton.isEnabled = canGoPrevious
        nextButton.isEnabled = canGoNext
    }

    /// Muestra el indicador mientras llega la nueva página.
    public func setLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        pageLabel.alpha = isLoading ? 0.45 : 1
    }

    private func setupView() {
        // Uso el color del sistema para que también se adapte al modo oscuro.
        backgroundColor = .systemBackground

        // Los botones usan estilos nativos para que el estado deshabilitado se entienda bien.
        previousButton.configuration = makeButtonConfiguration(
            title: "Anterior",
            symbolName: "chevron.left",
            isPrimary: false
        )
        nextButton.configuration = makeButtonConfiguration(
            title: "Siguiente",
            symbolName: "chevron.right",
            isPrimary: true
        )
        nextButton.configuration?.imagePlacement = .trailing

        pageLabel.font = .preferredFont(forTextStyle: .headline)
        pageLabel.textAlignment = .center
        pageLabel.textColor = .label
        pageLabel.adjustsFontForContentSizeCategory = true

        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        // En el centro dejo juntos el número de página y el indicador de carga.
        let centerStack = UIStackView(arrangedSubviews: [pageLabel, activityIndicator])
        centerStack.axis = .horizontal
        centerStack.alignment = .center
        centerStack.spacing = 6

        let stack = UIStackView(arrangedSubviews: [previousButton, centerStack, nextButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        // Esta línea separa la barra de la lista.
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    /// Prepara el estilo compartido de los dos botones.
    private func makeButtonConfiguration(
        title: String,
        symbolName: String,
        isPrimary: Bool
    ) -> UIButton.Configuration {
        var configuration: UIButton.Configuration = isPrimary ? .filled() : .tinted()
        configuration.title = title
        configuration.image = UIImage(systemName: symbolName)
        configuration.imagePadding = 6
        configuration.cornerStyle = .capsule
        configuration.buttonSize = .medium
        return configuration
    }

    // Reenvío los taps a la pantalla que está usando el componente.
    @objc private func previousTapped() { onPrevious?() }
    @objc private func nextTapped() { onNext?() }
}
