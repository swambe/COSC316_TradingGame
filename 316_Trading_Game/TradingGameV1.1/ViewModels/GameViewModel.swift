import Foundation
import SwiftUI
import Combine
import SwiftData

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published State
    @Published var gamePhase: GamePhase = .title
    @Published var stocks: [Stock] = []
    @Published var portfolio: [String: PortfolioHolding] = [:]
    @Published var cash: Double = 10000
    @Published var currentRound: Int = 1
    @Published var selectedDifficulty: GameDifficulty = .beginner
    @Published var roundTimeRemaining: Int = 60
    @Published var showNewsAlert: Bool = false
    @Published var priceAnimations: [String: Bool] = [:]  // symbol -> isAnimating
    @Published var profitFlash: Double? = nil
    @Published var selectedStock: Stock? = nil
    @Published var tradeQuantity: Int = 1
    @Published var showTradeConfirmation: Bool = false
    @Published var lastTradeResult: String = ""
    @Published var isMarketOpen: Bool = true
    @Published var marketCrashActive: Bool = false
    @Published var roundTrades: [TradeRecord] = []
    
    // MARK: - Private
    private var timer: Timer?
    private var priceUpdateTimer: Timer?
    private var modelContext: ModelContext?
    private var currentPlayer: PlayerProfile?
    
    // MARK: - Computed
    var totalPortfolioValue: Double {
        portfolio.values.reduce(0) { $0 + $1.currentValue }
    }
    
    var netWorth: Double {
        cash + totalPortfolioValue
    }
    
    var startingCash: Double {
        selectedDifficulty.startingCash
    }
    
    var profitLoss: Double {
        netWorth - startingCash
    }
    
    var profitLossPercent: Double {
        (profitLoss / startingCash) * 100
    }
    
    var targetProfit: Double {
        selectedDifficulty.targetProfit
    }
    
    var progressToTarget: Double {
        min(max(profitLoss / targetProfit, 0), 1.0)
    }
    
    var isWinning: Bool {
        profitLoss >= targetProfit
    }
    
    // MARK: - Setup
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func loadOrCreatePlayer(name: String = "Trader") {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<PlayerProfile>()
        let players = (try? context.fetch(descriptor)) ?? []
        if let existing = players.first {
            currentPlayer = existing
        } else {
            let player = PlayerProfile(name: name)
            context.insert(player)
            currentPlayer = player
        }
    }
    
    // MARK: - Game Flow
    func startGame(difficulty: GameDifficulty) {
        selectedDifficulty = difficulty
        cash = difficulty.startingCash
        currentRound = 1
        portfolio = [:]
        roundTrades = []
        marketCrashActive = false
        isMarketOpen = true
        
        setupStocks()
        gamePhase = .playing
        startRoundTimer()
        startPriceUpdates()
        
        currentPlayer?.gamesPlayed += 1
        try? modelContext?.save()
    }
    
    func endRound() {
        timer?.invalidate()
        priceUpdateTimer?.invalidate()
        
        // Check for market crash
        if Double.random(in: 0...1) < selectedDifficulty.marketCrashChance {
            triggerMarketCrash()
        }
        
        if currentRound >= selectedDifficulty.rounds {
            endGame()
        } else {
            gamePhase = .roundSummary
        }
    }
    
    func nextRound() {
        currentRound += 1
        roundTrades = []
        marketCrashActive = false
        
        updateStockPricesForNewRound()
        gamePhase = .playing
        startRoundTimer()
        startPriceUpdates()
    }
    
    func endGame() {
        timer?.invalidate()
        priceUpdateTimer?.invalidate()
        
        // Force sell all holdings
        for (symbol, holding) in portfolio {
            if let stock = stocks.first(where: { $0.symbol == symbol }) {
                let sellProfit = (stock.currentPrice - holding.averageBuyPrice) * Double(holding.shares)
                cash += stock.currentPrice * Double(holding.shares)
                
                let record = TradeRecord(
                    stockSymbol: symbol,
                    action: "SELL",
                    quantity: holding.shares,
                    price: stock.currentPrice,
                    profit: sellProfit,
                    difficulty: selectedDifficulty.name,
                    roundNumber: currentRound
                )
                roundTrades.append(record)
                currentPlayer?.tradeHistory.append(record)
            }
        }
        portfolio = [:]
        
        // Update player stats
        let finalProfit = netWorth - startingCash
        if finalProfit > (currentPlayer?.highScore ?? 0) {
            currentPlayer?.highScore = finalProfit
            currentPlayer?.bestDifficulty = selectedDifficulty.name
        }
        currentPlayer?.totalEarnings += finalProfit
        try? modelContext?.save()
        
        gamePhase = .gameOver
    }
    
    // MARK: - Trading
    func buyStock(_ stock: Stock, quantity: Int) {
        let totalCost = stock.currentPrice * Double(quantity)
        guard cash >= totalCost else { return }
        
        cash -= totalCost
        
        if var holding = portfolio[stock.symbol] {
            let totalShares = holding.shares + quantity
            let totalValue = (holding.averageBuyPrice * Double(holding.shares)) + totalCost
            holding.averageBuyPrice = totalValue / Double(totalShares)
            holding.shares = totalShares
            holding.currentValue = stock.currentPrice * Double(totalShares)
            portfolio[stock.symbol] = holding
        } else {
            var holding = PortfolioHolding(
                symbol: stock.symbol,
                shares: quantity,
                averageBuyPrice: stock.currentPrice
            )
            holding.currentValue = stock.currentPrice * Double(quantity)
            portfolio[stock.symbol] = holding
        }
        
        let record = TradeRecord(
            stockSymbol: stock.symbol,
            action: "BUY",
            quantity: quantity,
            price: stock.currentPrice,
            profit: 0,
            difficulty: selectedDifficulty.name,
            roundNumber: currentRound
        )
        roundTrades.append(record)
        currentPlayer?.tradeHistory.append(record)
        
        animatePriceChange(for: stock.symbol)
        lastTradeResult = "Bought \(quantity) shares of \(stock.symbol)"
        try? modelContext?.save()
    }
    
    func sellStock(_ stock: Stock, quantity: Int) {
        guard var holding = portfolio[stock.symbol], holding.shares >= quantity else { return }
        
        let saleValue = stock.currentPrice * Double(quantity)
        let costBasis = holding.averageBuyPrice * Double(quantity)
        let profit = saleValue - costBasis
        
        cash += saleValue
        holding.shares -= quantity
        
        if holding.shares == 0 {
            portfolio.removeValue(forKey: stock.symbol)
        } else {
            holding.currentValue = stock.currentPrice * Double(holding.shares)
            portfolio[stock.symbol] = holding
        }
        
        let record = TradeRecord(
            stockSymbol: stock.symbol,
            action: "SELL",
            quantity: quantity,
            price: stock.currentPrice,
            profit: profit,
            difficulty: selectedDifficulty.name,
            roundNumber: currentRound
        )
        roundTrades.append(record)
        currentPlayer?.tradeHistory.append(record)
        
        animatePriceChange(for: stock.symbol)
        
        withAnimation(.spring()) {
            profitFlash = profit
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.profitFlash = nil
        }
        
        lastTradeResult = profit >= 0 ? "Profit: +$\(String(format: "%.2f", profit))" : "Loss: $\(String(format: "%.2f", profit))"
        try? modelContext?.save()
    }
    
    func maxBuyQuantity(for stock: Stock) -> Int {
        Int(cash / stock.currentPrice)
    }
    
    func sharesHeld(for symbol: String) -> Int {
        portfolio[symbol]?.shares ?? 0
    }
    
    // MARK: - Private Helpers
    private func setupStocks() {
        stocks = [
            Stock(symbol: "AAPL", companyName: "Apple Inc.", currentPrice: 175.0, previousPrice: 175.0, priceHistory: [175.0],  volatility: 0.6),
            Stock(symbol: "TSLA", companyName: "Tesla Inc.", currentPrice: 245.0, previousPrice: 245.0, priceHistory: [245.0], volatility: 0.9),
            Stock(symbol: "NVDA", companyName: "NVIDIA Corp.", currentPrice: 480.0, previousPrice: 480.0, priceHistory: [480.0],  volatility: 0.85),
            Stock(symbol: "AMZN", companyName: "Amazon.com Inc.", currentPrice: 185.0, previousPrice: 185.0, priceHistory: [185.0], volatility: 0.65),
        ]
    }
    
    private func startRoundTimer() {
        roundTimeRemaining = selectedDifficulty.timePerRound
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                if self.roundTimeRemaining > 0 {
                    self.roundTimeRemaining -= 1
                } else {
                    self.endRound()
                }
            }
        }
    }
    
    private func startPriceUpdates() {
        priceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.tickPrices()
            }
        }
    }
    
    private func tickPrices() {
        for i in stocks.indices {
            let baseVolatility = stocks[i].volatility * selectedDifficulty.volatilityMultiplier
            let changePercent = Double.random(in: -baseVolatility...baseVolatility) * 0.03
            
            let newPrice = max(1.0, stocks[i].currentPrice * (1 + changePercent))
            
            withAnimation(.easeInOut(duration: 0.4)) {
                stocks[i].previousPrice = stocks[i].currentPrice
                stocks[i].currentPrice = newPrice
                stocks[i].priceHistory.append(newPrice)
                if stocks[i].priceHistory.count > 20 {
                    stocks[i].priceHistory.removeFirst()
                }
            }
            
            // Update portfolio values
            if var holding = portfolio[stocks[i].symbol] {
                holding.currentValue = newPrice * Double(holding.shares)
                portfolio[stocks[i].symbol] = holding
            }
        }
    }
    
    private func updateStockPricesForNewRound() {
        for i in stocks.indices {
            let baseVolatility = stocks[i].volatility * selectedDifficulty.volatilityMultiplier
            let changePercent = Double.random(in: -baseVolatility * 2...baseVolatility * 2) * 0.05
            let newPrice = max(1.0, stocks[i].currentPrice * (1 + changePercent))
            stocks[i].previousPrice = stocks[i].currentPrice
            stocks[i].currentPrice = newPrice
            stocks[i].priceHistory.append(newPrice)
        }
    }
    
    private func triggerMarketCrash() {
        marketCrashActive = true
        for i in stocks.indices {
            let crashPercent = Double.random(in: -0.25 ... -0.10)
            withAnimation(.easeInOut(duration: 1.0)) {
                stocks[i].previousPrice = stocks[i].currentPrice
                stocks[i].currentPrice = max(1.0, stocks[i].currentPrice * (1 + crashPercent))
            }
        }
    }
    
    private func animatePriceChange(for symbol: String) {
        priceAnimations[symbol] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.priceAnimations[symbol] = false
        }
    }
}
