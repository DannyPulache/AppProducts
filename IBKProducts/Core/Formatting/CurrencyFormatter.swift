//
//  CurrencyFormatter.swift
//  IBKProducts
//
//  Created by DannyPulache on 17/10/26.
//

import Foundation

/// Convierte un número como 190 en un texto como USD 190.00.
struct CurrencyFormatter {
    private let formatter: NumberFormatter

    init() {
        // Se configura una sola vez y después se reutiliza para cada precio.
        formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = FormattingConstants.currencyCode
        formatter.maximumFractionDigits = 2
    }

    func string(from value: Double) -> String {
        // Dejo un texto alternativo por si NumberFormatter no puede convertirlo.
        formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}
