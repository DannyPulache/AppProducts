//
//  AppStrings.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Guardo los textos visibles aquí para no escribirlos varias veces en las pantallas.
enum AppStrings {
    // Textos que aparecen en las dos pestañas principales.
    enum TabBar {
        static let products = "Productos"
        static let menu = "Menú"
    }

    enum ProductList {
        // Mensajes usados por el listado y sus distintos estados.
        static let title = "Productos"
        static let loading = "Cargando productos…"
        static let empty = "No hay productos disponibles."
        static let retry = "Reintentar"
        static let previous = "Anterior"
        static let next = "Siguiente"
        static let page = "Página %d de %d"
        static let noMoreTitle = "Fin del listado"
        static let noMoreMessage = "Ya no hay más productos que listar."
    }

    enum ProductDetail {
        // Títulos que se muestran dentro de la ficha del producto.
        static let title = "Detalle"
        static let description = "Descripción"
        static let category = "Categoría"
        static let price = "Precio"
        static let unknownCategory = "Sin categoría"
        static let missingDescription = "Este producto no tiene descripción."
    }

    enum Menu {
        // Nombres de las opciones disponibles en el menú.
        static let title = "Menú"
        static let sectionTitle = "Color de fondo del tab bar"
        static let blue = "Azul"
        static let green = "Verde"
        static let orange = "Naranja"
        static let purple = "Morado"
    }

    enum Error {
        // Mensajes generales para errores que el usuario sí puede ver.
        static let title = "Ocurrió un problema"
        static let generic = "No pudimos cargar los productos. Revisa tu conexión e inténtalo nuevamente."
        static let accept = "Aceptar"
    }
}

/// Mensajes que solo deberían aparecer si hay un error al programar la pantalla.
enum DeveloperMessages {
    static let coderInitializerUnavailable = "init(coder:) has not been implemented"
}
