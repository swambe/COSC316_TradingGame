import Foundation
import SwiftData

@Model
final class PlayerProfile {
    var id: UUID
    var name: String
    var totalEarnings: Double
    var highScore: Double
    var gamesPlayed: Int
    var bestDifficulty: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var tradeHistory: [TradeRecord]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.totalEarnings = 0
        self.highScore = 0
        self.gamesPlayed = 0
        self.bestDifficulty = "Beginner"
        self.createdAt = Date()
        self.tradeHistory = []
    }
    
    var formattedHighScore: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: highScore)) ?? "$0.00"
    }
}
