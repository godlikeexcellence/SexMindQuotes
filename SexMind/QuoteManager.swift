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
                let content = try String(contentsOf: url)
                quotes = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
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
