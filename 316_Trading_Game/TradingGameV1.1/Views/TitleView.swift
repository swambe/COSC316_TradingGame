import SwiftUI

struct TitleView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = -50
    @State private var subtitleOpacity: Double = 0
    @State private var buttonsOpacity: Double = 0
    @State private var tickerOffset: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    
    let tickerSymbols = ["AAPL +2.4%", "TSLA -1.8%", "NVDA +5.2%", "GME +22.1%", "JPM -0.3%", "AMZN +1.7%", "XOM -2.1%", "JNJ +0.8%"]
    
    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.08, blue: 0.15), Color(red: 0.02, green: 0.04, blue: 0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated grid lines
            GridBackgroundView()
            
            VStack(spacing: 0) {
                TickerTapeView(symbols: tickerSymbols)
                    .frame(height: 36)
                    .padding(.top, 60)
                
                Spacer()
            
                VStack( alignment: .center, spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseScale)
                            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulseScale)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 56, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(colors: [.green, Color(red: 0.2, green: 0.9, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    Text("SHORTS AND LADDERS")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.white, Color(white: 0.8)], startPoint: .top, endPoint: .bottom)
                        )
                        .tracking(4)
                        .offset(y: titleOffset)
                    
                    Text("TRADING SIMULATOR")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.green.opacity(0.8))
                        .tracking(6)
                        .opacity(subtitleOpacity)
                }
                
                Spacer()
                
                VStack(spacing: 14) {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            gameVM.gamePhase = .difficultySelect
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                            Text("PLAY")
                                .tracking(3)
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(colors: [Color.green, Color(red: 0.1, green: 0.8, blue: 0.4)], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(14)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            gameVM.gamePhase = .leaderboard
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "trophy.fill")
                            Text("LEADERBOARD")
                                .tracking(2)
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 32)
                .opacity(buttonsOpacity)
                
                Text("Trade smart. Beat the market.")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.top, 20)
                    .padding(.bottom, 50)
                    .opacity(buttonsOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                titleOffset = 0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.7)) {
                subtitleOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.6).delay(1.0)) {
                buttonsOpacity = 1.0
            }
            pulseScale = 1.12
        }
    }
}

// MARK: - Grid Background
struct GridBackgroundView: View {
    @State private var opacity: Double = 0
    
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 40
            var path = Path()
            
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
            
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            
            context.stroke(path, with: .color(.green.opacity(0.06)), lineWidth: 0.5)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Ticker Tape
struct TickerTapeView: View {
    let symbols: [String]
    @State private var offset: CGFloat = 0
    
    var tickerText: String {
        (symbols + symbols).joined(separator: "   •   ")
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Text(tickerText)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.green.opacity(0.7))
                    .fixedSize()
                    .offset(x: offset)
                    .onAppear {
                        let textWidth = CGFloat(tickerText.count) * 7.5
                        withAnimation(.linear(duration: Double(symbols.count) * 3).repeatForever(autoreverses: false)) {
                            offset = -textWidth / 2
                        }
                    }
            }
            .frame(width: geo.size.width, alignment: .leading)
            .clipped()
        }
        .background(Color.green.opacity(0.06))
    }
}

