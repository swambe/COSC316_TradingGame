import SwiftUI

struct GameBoardView: View {
    //MARK:
    @EnvironmentObject var gameVM: GameViewModel
    @State private var selectedTab: Int = 0
    @State private var showTradeSheet: Bool = false
    @State private var tradeStock: Stock? = nil
    @State private var headerPulse: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                GameHeaderView(onQuit: {
                    withAnimation { gameVM.gamePhase = .title }
                })
                
                NetWorthBannerView()
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                HStack(spacing: 0) {
                    TabButton(title: "Market", icon: "chart.bar.fill", isSelected: selectedTab == 0) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 }
                    }
                    TabButton(title: "Portfolio", icon: "briefcase.fill", isSelected: selectedTab == 1) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                TabView(selection: $selectedTab) {
                    MarketView(onTrade: { stock in
                        tradeStock = stock
                        showTradeSheet = true
                    })
                    .tag(0)
                    
                    PortfolioView(onTrade: { stock in
                        tradeStock = stock
                        showTradeSheet = true
                    })
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            // Floating profit/loss flash
            if let flash = gameVM.profitFlash {
                ProfitFlashView(amount: flash)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(10)
            }
            
            // Market Crash Banner
            if gameVM.marketCrashActive {
                MarketCrashBanner()
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(11)
            }
        }
        .sheet(isPresented: $showTradeSheet) {
            if let stock = tradeStock {
                TradeSheetView(stock: stock)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

// MARK: - Game Header
struct GameHeaderView: View {
    @EnvironmentObject var gameVM: GameViewModel
    let onQuit: () -> Void
    @State private var timerFlash = false
    
    var timerColor: Color {
        if gameVM.roundTimeRemaining <= 5 { return .red }
        if gameVM.roundTimeRemaining <= 15 { return .orange }
        return .green
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("ROUND \(gameVM.currentRound)/\(gameVM.selectedDifficulty.rounds)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(1)
                Text(gameVM.selectedDifficulty.name.uppercased())
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(gameVM.selectedDifficulty.color)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(timerColor.opacity(0.2), lineWidth: 3)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: CGFloat(gameVM.roundTimeRemaining) / CGFloat(gameVM.selectedDifficulty.timePerRound))
                    .stroke(timerColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: gameVM.roundTimeRemaining)
                
                Text("\(gameVM.roundTimeRemaining)")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(timerColor)
                    .scaleEffect(gameVM.roundTimeRemaining <= 5 && timerFlash ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.3).repeatForever(), value: timerFlash)
            }
            
            Spacer()
            
            Button(action: onQuit) {
                Text("QUIT")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
        .background(Color(red: 0.05, green: 0.07, blue: 0.12))
        .onChange(of: gameVM.roundTimeRemaining) { _, val in
            if val <= 5 { timerFlash = true }
        }
    }
}

// MARK: - Net Worth Banner
struct NetWorthBannerView: View {
    @EnvironmentObject var gameVM: GameViewModel
    
    var plColor: Color {
        gameVM.profitLoss >= 0 ? .green : .red
    }
    
    var plSign: String { gameVM.profitLoss >= 0 ? "+" : "" }
    var plArrow: String { gameVM.profitLoss >= 0 ? "arrow.up.right" : "arrow.down.right" }
    var plText: String { "\(plSign)$\(String(format: "%.2f", gameVM.profitLoss))" }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text("NET WORTH")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(1)
                Text("$\(String(format: "%.2f", gameVM.netWorth))")
                    .font(.system(size: 22, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text("P/L")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(1)
                HStack(spacing: 4) {
                    Image(systemName: plArrow)
                        .font(.system(size: 12, weight: .bold))
                    Text(plText)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundColor(plColor)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .overlay(
            // Progress bar at bottom
            GeometryReader { geo in
                VStack {
                    Spacer()
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 3)
                        Rectangle()
                            .fill(plColor)
                            .frame(width: geo.size.width * gameVM.progressToTarget, height: 3)
                            .animation(.easeInOut(duration: 0.5), value: gameVM.progressToTarget)
                    }
                }
            }
        )
        .cornerRadius(12)
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .black : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(isSelected ? Color.green : Color.clear)
            .cornerRadius(10)
        }
    }
}

// MARK: - Profit Flash View
struct ProfitFlashView: View {
    let amount: Double
    
    var flashColor: Color { amount >= 0 ? .green : .red }
    var flashText: String {
        amount >= 0
            ? "+$\(String(format: "%.2f", amount))"
            : "-$\(String(format: "%.2f", abs(amount)))"
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(flashText)
                .font(.system(size: 28, weight: .black, design: .monospaced))
                .foregroundColor(flashColor)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(flashColor.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(flashColor.opacity(0.4), lineWidth: 1)
                        )
                )
            Spacer()
        }
    }
}

// MARK: - Market Crash Banner
struct MarketCrashBanner: View {
    @State private var shake = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("MARKET CRASH!")
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                    .foregroundColor(.red)
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            }
            .padding()
            .background(Color.red.opacity(0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red.opacity(0.6), lineWidth: 2)
            )
            .cornerRadius(12)
            .offset(x: shake ? -8 : 8)
            .animation(.easeInOut(duration: 0.08).repeatCount(8, autoreverses: true), value: shake)
            .onAppear { shake = true }
            .padding(.bottom, 100)
        }
    }
}
