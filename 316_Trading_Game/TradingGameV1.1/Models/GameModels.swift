import Foundation
import SwiftUI

// MARK: - Stock Model
struct Stock: Identifiable {
    let id = UUID()
    var symbol: String
    var companyName: String
    var currentPrice: Double
    var previousPrice: Double
    var priceHistory: [Double]
    var volatility: Double
    
    var priceChange: Double {
        currentPrice - previousPrice
    }
    
    var priceChangePercent: Double {
        guard previousPrice > 0 else { return 0 }
        return (priceChange / previousPrice) * 100
    }
    
    var isUp: Bool {
        currentPrice >= previousPrice
    }
    
    var formattedPrice: String {
        String(format: "$%.2f", currentPrice)
    }
    
    var formattedChange: String {
        let sign = priceChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", priceChange)) (\(sign)\(String(format: "%.1f", priceChangePercent))%)"
    }
}

// MARK: - Game Difficulty
struct GameDifficulty: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var startingCash: Double
    var rounds: Int
    var volatilityMultiplier: Double
    var marketCrashChance: Double
    var targetProfit: Double
    var color: Color
    var iconName: String
    var timePerRound: Int
    
    static let beginner = GameDifficulty(
        name: "Sunday Trader",
        description: "Slow market, forgiving volatility. Great for learning the ropes.",
        startingCash: 10000,
        rounds: 10,
        volatilityMultiplier: 0.5,
        marketCrashChance: 0.02,
        targetProfit: 2000,
        color: .green,
        iconName: "leaf.fill",
        timePerRound: 60
    )
    
    static let intermediate = GameDifficulty(
        name: "Alpha Dog",
        description: "Real-world volatility. You'll need strategy to profit.",
        startingCash: 10000,
        rounds: 12,
        volatilityMultiplier: 1.0,
        marketCrashChance: 0.08,
        targetProfit: 4000,
        color: .orange,
        iconName: "chart.line.uptrend.xyaxis",
        timePerRound: 45
    )
    
    static let expert = GameDifficulty(
        name: "Day Trader",
        description: "High volatility, frequent crashes. Only the sharpest traders survive.",
        startingCash: 10000,
        rounds: 15,
        volatilityMultiplier: 2.0,
        marketCrashChance: 0.15,
        targetProfit: 8000,
        color: .red,
        iconName: "flame.fill",
        timePerRound: 30
    )
    
    static let wallStreet = GameDifficulty(
        name: "Wall Street",
        description: "Extreme conditions, black swan events, no mercy. Beat the Street if you dare.",
        startingCash: 10000,
        rounds: 20,
        volatilityMultiplier: 3.5,
        marketCrashChance: 0.25,
        targetProfit: 15000,
        color: .purple,
        iconName: "building.columns.fill",
        timePerRound: 20
    )
    
    static let all: [GameDifficulty] = [.beginner, .intermediate, .expert, .wallStreet]
}

// MARK: - Portfolio Holding
struct PortfolioHolding: Identifiable {
    let id = UUID()
    var symbol: String
    var shares: Int
    var averageBuyPrice: Double
    
    var currentValue: Double = 0
    
    var totalCost: Double {
        Double(shares) * averageBuyPrice
    }
    
    var unrealizedPL: Double {
        currentValue - totalCost
    }
    
    var unrealizedPLPercent: Double {
        guard totalCost > 0 else { return 0 }
        return (unrealizedPL / totalCost) * 100
    }
}

// MARK: - Game State
enum GamePhase {
    case title
    case difficultySelect
    case playing
    case roundSummary
    case gameOver
    case leaderboard
}
