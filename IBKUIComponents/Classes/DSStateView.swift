//
//  DSStateView.swift
//  IBKUIComponents
//
//  Created by DannyPulache on 17/10/26.
//

import UIKit

/// Vista que uso cuando la lista está cargando, vacía o con error.
public final class DSStateView: UIView {
    // Los mismos elementos cambian de contenido según el estado.
    private let symbolImageView = UIImageView()
    private let indicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private let button = UIButton(type: .system)
    private var action: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func showLoading(message: String) {
        // Durante la carga oculto el ícono y el botón, y dejo girando el indicador.
        messageLabel.text = message
        symbolImageView.isHidden = true
        button.isHidden = true
        indicator.startAnimating()
    }

    public func showMessage(
        _ message: String,
        buttonTitle: String,
        symbolName: String = "shippingbox",
        action: @escaping () -> Void
    ) {
        // Para vacío o error muestro un símbolo, el mensaje y una acción.
        indicator.stopAnimating()
        symbolImageView.image = UIImage(systemName: symbolName)
        symbolImageView.isHidden = false
        messageLabel.text = message
        button.configuration?.title = buttonTitle
        button.isHidden = false
        self.action = action
    }

    private func setupView() {
        // Configuro una vez la apariencia y dejo que los métodos cambien el contenido.
        symbolImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 42, weight: .medium)
        symbolImageView.tintColor = .systemBlue
        symbolImageView.contentMode = .scaleAspectFit
        symbolImageView.isAccessibilityElement = false

        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.font = .preferredFont(forTextStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true
        button.configuration = .borderedProminent()
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        // El stack centra todo sin tener que posicionar cada elemento por separado.
        let stack = UIStackView(arrangedSubviews: [symbolImageView, indicator, messageLabel, button])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
        ])
    }

    // Ejecuta el reintento que configuró la pantalla.
    @objc private func buttonTapped() { action?() }
}
