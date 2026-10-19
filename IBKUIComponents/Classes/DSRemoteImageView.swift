//
//  DSRemoteImageView.swift
//  IBKUIComponents
//
//  Created by DannyPulache on 17/10/26.
//

import UIKit

/// UIImageView que descarga una imagen y muestra un ícono mientras espera.
public final class DSRemoteImageView: UIImageView {
    // La caché vive durante la sesión para no bajar dos veces la misma imagen.
    private static let imageCache = NSCache<NSURL, UIImage>()
    // Guardo la tarea para poder cancelarla si la pantalla se cierra.
    private var task: URLSessionDataTask?

    public func load(url: URL?) {
        // Cancelo cualquier carga anterior antes de empezar otra.
        cancelImageLoad()
        image = UIImage(systemName: "photo")
        tintColor = .tertiaryLabel
        guard let url else { return }

        // Si ya vi esta imagen, la muestro directamente desde memoria.
        if let cachedImage = Self.imageCache.object(forKey: url as NSURL) {
            image = cachedImage
            return
        }

        // La descarga se hace fuera del hilo principal para no trabar la interfaz.
        task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            Self.imageCache.setObject(image, forKey: url as NSURL)
            // Los cambios visuales siempre regresan al hilo principal.
            DispatchQueue.main.async {
                guard let self else { return }
                UIView.transition(
                    with: self,
                    duration: 0.25,
                    options: .transitionCrossDissolve
                ) {
                    self.image = image
                }
            }
        }
        task?.resume()
    }

    public func cancelImageLoad() {
        // También limpio la referencia para no dejar una tarea vieja guardada.
        task?.cancel()
        task = nil
    }
}
