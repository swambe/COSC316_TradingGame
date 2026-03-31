import SwiftUI
import SwiftData

struct LeaderboardView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TradeRecord.timestamp, order: .reverse) private var allTrades: [TradeRecord]
    @Query private var players: [PlayerProfile]
    
    @State private var visible = false
    @State private var selectedTab = 0
    
    var recentTrades: [TradeRecord] {
        Array(allTrades.prefix(30))
    }
    
    var player: PlayerProfile? { players.first }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.08, blue: 0.15), Color(red: 0.02, green: 0.04, blue: 0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            GridBackgroundView()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        withAnimation { gameVM.gamePhase = .title }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("YOUR STATS")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(2)
                    Spacer()
                    Color.clear.frame(width: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                if let p = player {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Trophy card
                            VStack(spacing: 12) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(.yellow)
                                    .scaleEffect(visible ? 1 : 0.5)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: visible)
                                
                                Text("HIGH SCORE")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.4))
                                    .tracking(2)
                                
                                Text(p.formattedHighScore)
                                    .font(.system(size: 32, weight: .black, design: .monospaced))
                                    .foregroundColor(.yellow)
                                
                                Text("Best on \(p.bestDifficulty)")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(Color.yellow.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(16)
                            
                            // Stats grid
                            HStack(spacing: 12) {
                                SummaryStatCard(title: "GAMES PLAYED", value: "\(p.gamesPlayed)", color: .blue)
                                SummaryStatCard(title: "TOTAL EARNINGS", value: "$\(Int(p.totalEarnings).formatted())", color: p.totalEarnings >= 0 ? .green : .red)
                            }
                            
                            // Recent trades
                            if !recentTrades.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("RECENT TRADES (\(recentTrades.count))")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.4))
                                        .tracking(2)
                                    
                                    ForEach(recentTrades.prefix(15)) { trade in
                                        TradeHistoryRow(trade: trade)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white.opacity(0.2))
                                    Text("No trades yet. Play a game!")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 30)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.4)) { visible = true }
        }
    }
}

struct TradeHistoryRow: View {
    let trade: TradeRecord
    
    var isBuy: Bool { trade.action == "BUY" }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill((isBuy ? Color.green : Color.red).opacity(0.15))
                    .frame(width: 40, height: 36)
                Text(trade.action)
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(isBuy ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(trade.stockSymbol)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("\(trade.quantity) shares @ \(trade.formattedPrice)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if !isBuy && trade.profit != 0 {
                    Text("\(trade.profit >= 0 ? "+" : "")$\(String(format: "%.2f", trade.profit))")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(trade.profit >= 0 ? .green : .red)
                }
                Text(trade.difficulty)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
        .cornerRadius(10)
    }
}
