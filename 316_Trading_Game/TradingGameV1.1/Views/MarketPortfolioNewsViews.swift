import SwiftUI

// MARK: - Market View
struct MarketView: View {
    @EnvironmentObject var gameVM: GameViewModel
    let onTrade: (Stock) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(gameVM.stocks) { stock in
                    StockRowView(stock: stock, onTap: { onTrade(stock) })
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
    }
}

// MARK: - Stock Row
struct StockRowView: View {
    @EnvironmentObject var gameVM: GameViewModel
    let stock: Stock
    let onTap: () -> Void
    @State private var priceScale: CGFloat = 1.0
    
    var isAnimating: Bool {
        gameVM.priceAnimations[stock.symbol] ?? false
    }
    
    var held: Int {
        gameVM.sharesHeld(for: stock.symbol)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Symbol badge
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(stock.isUp ? Color.green.opacity(0.12) : Color.red.opacity(0.12))
                        .frame(width: 50, height: 50)
                    Text(String(stock.symbol.prefix(3)))
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(stock.isUp ? .green : .red)
                }
                
                // Name + spark
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(stock.symbol)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        if held > 0 {
                            Text("×\(held)")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    Text(stock.companyName)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                        .lineLimit(1)
                    
                    // Mini sparkline
                    SparklineView(prices: stock.priceHistory)
                        .frame(width: 60, height: 18)
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 4) {
                    Text(stock.formattedPrice)
                        .font(.system(size: 17, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .scaleEffect(isAnimating ? 1.15 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                    
                    HStack(spacing: 3) {
                        Image(systemName: stock.isUp ? "triangle.fill" : "triangle.fill")
                            .font(.system(size: 8))
                            .rotationEffect(.degrees(stock.isUp ? 0 : 180))
                        Text(String(format: "%.1f%%", abs(stock.priceChangePercent)))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(stock.isUp ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background((stock.isUp ? Color.green : Color.red).opacity(0.12))
                    .cornerRadius(6)
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isAnimating ? (stock.isUp ? Color.green : Color.red).opacity(0.5) : Color.clear, lineWidth: 1.5)
                    .animation(.easeInOut(duration: 0.3), value: isAnimating)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sparkline
struct SparklineView: View {
    let prices: [Double]
    
    var body: some View {
        GeometryReader { geo in
            if prices.count >= 2 {
                let minP = prices.min() ?? 0
                let maxP = prices.max() ?? 1
                let range = maxP - minP == 0 ? 1 : maxP - minP
                let points: [CGPoint] = prices.enumerated().map { i, p in
                    CGPoint(
                        x: geo.size.width * CGFloat(i) / CGFloat(prices.count - 1),
                        y: geo.size.height * CGFloat(1 - (p - minP) / range)
                    )
                }
                let isUp = (prices.last ?? 0) >= (prices.first ?? 0)
                
                Path { path in
                    path.move(to: points[0])
                    for pt in points.dropFirst() {
                        path.addLine(to: pt)
                    }
                }
                .stroke(isUp ? Color.green : Color.red, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

// MARK: - Portfolio View
struct PortfolioView: View {
    @EnvironmentObject var gameVM: GameViewModel
    let onTrade: (Stock) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Cash card
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CASH")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                            Text("$\(String(format: "%.2f", gameVM.cash))")
                                .font(.system(size: 18, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding(14)
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)
                
                if gameVM.portfolio.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "briefcase")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.2))
                        Text("No positions yet.\nGo buy some stocks!")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    ForEach(gameVM.portfolio.values.sorted(by: { $0.symbol < $1.symbol })) { holding in
                        if let stock = gameVM.stocks.first(where: { $0.symbol == holding.symbol }) {
                            PortfolioRowView(holding: holding, stock: stock, onTap: { onTrade(stock) })
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
    }
}

struct PortfolioRowView: View {
    let holding: PortfolioHolding
    let stock: Stock
    let onTap: () -> Void
    
    var unrealizedPL: Double {
        (stock.currentPrice - holding.averageBuyPrice) * Double(holding.shares)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(holding.symbol)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("×\(holding.shares) shares")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    Text("Avg: $\(String(format: "%.2f", holding.averageBuyPrice))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", stock.currentPrice * Double(holding.shares)))")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    let isGain = unrealizedPL >= 0
                    Text("\(isGain ? "+" : "")$\(String(format: "%.2f", unrealizedPL))")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(isGain ? .green : .red)
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
