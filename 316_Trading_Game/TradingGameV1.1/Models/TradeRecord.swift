import Foundation
import SwiftData

@Model
final class TradeRecord {
    var id: UUID
    var stockSymbol: String
    var action: String
    var quantity: Int
    var price: Double
    var profit: Double
    var timestamp: Date
    var difficulty: String
    var roundNumber: Int
    
    init(stockSymbol: String, action: String, quantity: Int, price: Double, profit: Double = 0, difficulty: String, roundNumber: Int) {
        self.id = UUID()
        self.stockSymbol = stockSymbol
        self.action = action
        self.quantity = quantity
        self.price = price
        self.profit = profit
        self.timestamp = Date()
        self.difficulty = difficulty
        self.roundNumber = roundNumber
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: price)) ?? "$0.00"
    }
    
    var isProfit: Bool {
        profit >= 0
    }
}
