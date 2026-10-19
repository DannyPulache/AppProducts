//
//  LayoutConstants.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import UIKit

/// Medidas que se usan en el listado y en el detalle.
enum LayoutConstants {
    enum ProductList {
        // Cada página pide 20 productos, como se solicita en los requisitos.
        nonisolated static let pageSize = 20
        static let estimatedRowHeight: CGFloat = 84
        static let paginationHeight: CGFloat = 82
    }

    enum ProductDetail {
        // Mantengo estas medidas juntas para que las tarjetas tengan el mismo estilo.
        static let imageHeight: CGFloat = 300
        static let contentInset: CGFloat = 16
        static let sectionSpacing: CGFloat = 14
        static let cardCornerRadius: CGFloat = 22
        static let cardInset: CGFloat = 18
    }
}
