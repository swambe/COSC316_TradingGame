import SwiftUI

// MARK: - Round Summary View
struct RoundSummaryView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @State private var visible = false
    @State private var statsVisible = false
    
    var roundPL: Double {
        gameVM.roundTrades.reduce(0) { $0 + $1.profit }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.08, blue: 0.15), Color(red: 0.02, green: 0.04, blue: 0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            GridBackgroundView()
            
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Text("R\(gameVM.currentRound)")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                    .scaleEffect(visible ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: visible)
                    
                    Text("ROUND COMPLETE")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(2)
                        .opacity(visible ? 1 : 0)
                        .animation(.easeIn(duration: 0.4).delay(0.3), value: visible)
                    
                    Text("\(gameVM.selectedDifficulty.rounds - gameVM.currentRound) rounds remaining")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                        .opacity(visible ? 1 : 0)
                        .animation(.easeIn(duration: 0.4).delay(0.4), value: visible)
                }
                
                if gameVM.marketCrashActive {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Market crash occurred this round!")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.red)
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                    .opacity(statsVisible ? 1 : 0)
                }
                
                // Stats grid
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        SummaryStatCard(title: "NET WORTH", value: "$\(String(format: "%.0f", gameVM.netWorth))", color: .white)
                        SummaryStatCard(title: "CASH", value: "$\(String(format: "%.0f", gameVM.cash))", color: .green)
                    }
                    HStack(spacing: 12) {
                        SummaryStatCard(title: "TOTAL P/L", value: "\(gameVM.profitLoss >= 0 ? "+" : "")$\(String(format: "%.0f", gameVM.profitLoss))", color: gameVM.profitLoss >= 0 ? .green : .red)
                        SummaryStatCard(title: "TARGET", value: "$\(Int(gameVM.targetProfit).formatted())", color: .orange)
                    }
                    
                    // Progress bar
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("GOAL PROGRESS")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                                .tracking(1)
                            Spacer()
                            Text("\(Int(gameVM.progressToTarget * 100))%")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
                                    .frame(width: geo.size.width * (statsVisible ? gameVM.progressToTarget : 0), height: 8)
                                    .animation(.easeInOut(duration: 1.0).delay(0.5), value: statsVisible)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .opacity(statsVisible ? 1 : 0)
                .offset(y: statsVisible ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: statsVisible)
                
                // Trade summary
                if !gameVM.roundTrades.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("THIS ROUND'S TRADES (\(gameVM.roundTrades.count))")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1)
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(gameVM.roundTrades) { trade in
                                    MiniTradeTag(trade: trade)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .opacity(statsVisible ? 1 : 0)
                    .animation(.easeIn(duration: 0.4).delay(0.7), value: statsVisible)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation { gameVM.nextRound() }
                }) {
                    HStack {
                        Text("NEXT ROUND")
                            .tracking(2)
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(LinearGradient(colors: [.green, Color(red: 0.1, green: 0.8, blue: 0.4)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(statsVisible ? 1 : 0)
                .animation(.easeIn(duration: 0.4).delay(0.8), value: statsVisible)
            }
            .padding(.top, 80)
        }
        .onAppear {
            visible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                statsVisible = true
            }
        }
    }
}

struct SummaryStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
                .tracking(1)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct MiniTradeTag: View {
    let trade: TradeRecord
    
    var body: some View {
        HStack(spacing: 5) {
            Text(trade.action)
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundColor(trade.action == "BUY" ? .green : .red)
            Text(trade.stockSymbol)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text("×\(trade.quantity)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.07))
        .cornerRadius(8)
    }
}

// MARK: - Game Over View
struct GameOverView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @State private var visible = false
    @State private var confettiActive = false
    @State private var numberScale: CGFloat = 0.3
    
    var isWin: Bool { gameVM.isWinning }
    var finalAmount: Double { gameVM.netWorth }
    
    var plSign: String { gameVM.profitLoss >= 0 ? "+" : "" }
    var plText: String { "\(plSign)$\(String(format: "%.2f", gameVM.profitLoss))" }
    var plColor: Color { gameVM.profitLoss >= 0 ? .green : .red }
    
    var returnSign: String { gameVM.profitLossPercent >= 0 ? "+" : "" }
    var returnText: String { "\(returnSign)\(String(format: "%.1f", gameVM.profitLossPercent))%" }
    var returnColor: Color { gameVM.profitLossPercent >= 0 ? .green : .red }
    
    var headerEmoji: String { isWin ? "🏆" : "📉" }
    var headerTitle: String { isWin ? "GOAL ACHIEVED!" : "GAME OVER" }
    var headerColor: Color { isWin ? .yellow : .white }
    
    var performanceRating: String {
        let pct = gameVM.profitLossPercent
        if pct >= 150 { return "LEGENDARY" }
        if pct >= 100 { return "INCREDIBLE" }
        if pct >= 50 { return "EXCELLENT" }
        if pct >= 25 { return "GOOD" }
        if pct >= 0 { return "AVERAGE" }
        if pct >= -25 { return "BELOW AVG" }
        return "BANKRUPT"
    }
    
    var ratingColor: Color {
        let pct = gameVM.profitLossPercent
        if pct >= 50 { return .yellow }
        if pct >= 0 { return .green }
        if pct >= -25 { return .orange }
        return .red
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.08, blue: 0.15), Color(red: 0.02, green: 0.04, blue: 0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            GridBackgroundView()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Result header
                VStack(spacing: 14) {
                    Text(headerEmoji)
                        .font(.system(size: 64))
                        .scaleEffect(visible ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.1), value: visible)
                    
                    Text(headerTitle)
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(headerColor)
                        .tracking(2)
                    
                    Text(performanceRating)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(ratingColor)
                        .tracking(4)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(ratingColor.opacity(0.15))
                        .cornerRadius(8)
                }
                .opacity(visible ? 1 : 0)
                .animation(.easeIn(duration: 0.5).delay(0.3), value: visible)
                
                // Final stats
                VStack(spacing: 12) {
                    // Big net worth
                    VStack(spacing: 4) {
                        Text("FINAL NET WORTH")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(2)
                        Text("$\(String(format: "%.2f", finalAmount))")
                            .font(.system(size: 38, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .scaleEffect(numberScale)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.5), value: numberScale)
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(16)
                    
                    HStack(spacing: 10) {
                        SummaryStatCard(title: "TOTAL P/L", value: plText, color: plColor)
                        SummaryStatCard(title: "RETURN", value: returnText, color: returnColor)
                    }
                    
                    HStack(spacing: 10) {
                        SummaryStatCard(title: "DIFFICULTY", value: gameVM.selectedDifficulty.name.uppercased(), color: gameVM.selectedDifficulty.color)
                        SummaryStatCard(title: "ROUNDS", value: "\(gameVM.selectedDifficulty.rounds)", color: .blue)
                    }
                }
                .padding(.horizontal, 24)
                .opacity(visible ? 1 : 0)
                .offset(y: visible ? 0 : 30)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.6), value: visible)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        withAnimation { gameVM.gamePhase = .difficultySelect }
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.clockwise")
                            Text("PLAY AGAIN")
                                .tracking(2)
                        }
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(LinearGradient(colors: [.green, Color(red: 0.1, green: 0.8, blue: 0.4)], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(14)
                    }
                    
                    Button(action: {
                        withAnimation { gameVM.gamePhase = .title }
                    }) {
                        Text("MAIN MENU")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .opacity(visible ? 1 : 0)
                .animation(.easeIn(duration: 0.4).delay(0.9), value: visible)
            }
        }
        .onAppear {
            visible = true
            numberScale = 1.0
        }
    }
}
