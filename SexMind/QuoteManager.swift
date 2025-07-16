import Foundation

class QuoteManager {
    static let shared = QuoteManager()
    private(set) var quotes: [String] = []

    init() {
        loadQuotes()
    }

    private func loadQuotes() {
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "txt") {
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                quotes = content.components(separatedBy: CharacterSet.newlines)
                    .filter { !$0.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty }
            } catch {
                print("⚠️ Failed to load quotes.txt: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ quotes.txt not found in bundle.")
        }
    }

    func randomQuote() -> String {
        quotes.randomElement() ?? "You are enough."
    }
}

