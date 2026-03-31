import SwiftUI

struct TradeSheetView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @Environment(\.dismiss) var dismiss
    let stock: Stock
    
    @State private var tradeMode: TradeMode = .buy
    @State private var quantity: Int = 1
    @State private var showConfirm = false
    @State private var confirmMessage = ""
    
    enum TradeMode { case buy, sell }
    
    var maxBuy: Int { gameVM.maxBuyQuantity(for: stock) }
    var maxSell: Int { gameVM.sharesHeld(for: stock.symbol) }
    var totalCost: Double { stock.currentPrice * Double(quantity) }
    var estimatedPL: Double {
        if tradeMode == .sell {
            let avgCost = gameVM.portfolio[stock.symbol]?.averageBuyPrice ?? stock.currentPrice
            return (stock.currentPrice - avgCost) * Double(quantity)
        }
        return 0
    }
    
    var canTrade: Bool {
        if tradeMode == .buy {
            return quantity <= maxBuy && maxBuy > 0
        } else {
            return quantity <= maxSell && maxSell > 0
        }
    }
    
    var tradeButtonGradient: LinearGradient {
        if !canTrade {
            return LinearGradient(colors: [Color.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
        }
        if tradeMode == .buy {
            return LinearGradient(colors: [.green, Color(red: 0.1, green: 0.8, blue: 0.4)], startPoint: .leading, endPoint: .trailing)
        }
        return LinearGradient(colors: [.red, Color(red: 0.9, green: 0.2, blue: 0.2)], startPoint: .leading, endPoint: .trailing)
    }
    
    var tradeButtonLabel: String {
        tradeMode == .buy ? "BUY \(quantity) SHARES" : "SELL \(quantity) SHARES"
    }
    
    var maxForMode: Int {
        tradeMode == .buy ? maxBuy : maxSell
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stock.symbol)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text(stock.companyName)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(stock.formattedPrice)
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text(stock.formattedChange)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(stock.isUp ? .green : .red)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                SparklineView(prices: stock.priceHistory)
                    .frame(height: 50)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.top, 16)
                
                HStack(spacing: 0) {
                    TradeModeButton(title: "BUY", isSelected: tradeMode == .buy, color: .green) {
                        withAnimation(.easeInOut(duration: 0.15)) { tradeMode = .buy }
                        quantity = 1
                    }
                    TradeModeButton(title: "SELL", isSelected: tradeMode == .sell, color: .red) {
                        withAnimation(.easeInOut(duration: 0.15)) { tradeMode = .sell }
                        quantity = 1
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("QUANTITY")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1)
                        Spacer()
                        Text("Max: \(maxForMode)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: { if quantity > 1 { quantity -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Text("\(quantity)")
                            .font(.system(size: 36, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(minWidth: 70)
                        
                        Button(action: {
                            if quantity < maxForMode { quantity += 1 }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    QuickSelectButtons(maxShares: maxForMode, quantity: $quantity)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("TOTAL")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text("$\(String(format: "%.2f", totalCost))")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    if tradeMode == .sell && gameVM.sharesHeld(for: stock.symbol) > 0 {
                        HStack {
                            Text("EST. P/L")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.white.opacity(0.4))
                            Spacer()
                            Text("\(estimatedPL >= 0 ? "+" : "")$\(String(format: "%.2f", estimatedPL))")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(estimatedPL >= 0 ? .green : .red)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                Button(action: {
                    if tradeMode == .buy {
                        gameVM.buyStock(stock, quantity: quantity)
                    } else {
                        gameVM.sellStock(stock, quantity: quantity)
                    }
                    dismiss()
                }) {
                    Text(tradeButtonLabel)
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(tradeButtonGradient)
                        .cornerRadius(14)
                }
                .disabled(!canTrade)
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
    }
}

struct QuickSelectButtons: View {
    let maxShares: Int
    @Binding var quantity: Int
    
    func sharesForPercent(_ pct: Int) -> Int {
        max(1, Int(Double(maxShares) * Double(pct) / 100.0))
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach([25, 50, 75, 100], id: \.self) { pct in
                Button(action: {
                    quantity = sharesForPercent(pct)
                }) {
                    Text("\(pct)%")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                }
            }
        }
    }
}

struct TradeModeButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var underlneColor: Color {
        isSelected ? color : Color.clear
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .tracking(1)
                .foregroundColor(isSelected ? color : .white.opacity(0.4))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? color.opacity(0.15) : Color.clear)
                .overlay(
                    Rectangle()
                        .fill(underlneColor)
                        .frame(height: 2),
                    alignment: .bottom
                )
        }
    }
}
