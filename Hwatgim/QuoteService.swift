//
//  QuoteService.swift
//  Hwatgim
//

import Foundation

struct Quote: Codable, Identifiable {
    let id: Int
    let text: String
    let author: String
}

struct QuoteService {
    static func loadQuotes() -> [Quote] {
        guard let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quotes = try? JSONDecoder().decode([Quote].self, from: data) else {
            return []
        }
        return quotes
    }

    static func randomQuote() -> Quote? {
        let quotes = loadQuotes()
        return quotes.randomElement()
    }
}
