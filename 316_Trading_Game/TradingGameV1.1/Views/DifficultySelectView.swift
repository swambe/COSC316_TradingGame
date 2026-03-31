import SwiftUI

struct DifficultySelectView: View {
    @EnvironmentObject var gameVM: GameViewModel
    @State private var selectedIndex: Int? = nil
    @State private var cardsVisible = false
    @State private var headerVisible = false
    
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
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                VStack(spacing: 8) {
                    Text("SELECT DIFFICULTY")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    Text("Higher difficulty = higher rewards")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.top, 16)
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : -20)
                
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(Array(GameDifficulty.all.enumerated()), id: \.offset) { index, difficulty in
                            DifficultyCard(
                                difficulty: difficulty,
                                isSelected: selectedIndex == index,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedIndex = index
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        gameVM.startGame(difficulty: difficulty)
                                    }
                                }
                            )
                            .opacity(cardsVisible ? 1 : 0)
                            .offset(y: cardsVisible ? 0 : 40)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08), value: cardsVisible)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { headerVisible = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                cardsVisible = true
            }
        }
    }
}

struct DifficultyCard: View {
    let difficulty: GameDifficulty
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(difficulty.color.opacity(0.2))
                        .frame(width: 54, height: 54)
                    Image(systemName: difficulty.iconName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(difficulty.color)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(difficulty.name.uppercased())
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(1)
                        
                        Spacer()
                        
                        // Target
                        Text("Goal: +$\(Int(difficulty.targetProfit).formatted())")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(difficulty.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(difficulty.color.opacity(0.15))
                            .cornerRadius(6)
                    }
                    
                    Text(difficulty.description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                    
                    // Stats row
                    HStack(spacing: 14) {
                        StatBadge(icon: "clock", value: "\(difficulty.timePerRound)s/round")
                        StatBadge(icon: "arrow.clockwise", value: "\(difficulty.rounds) rounds")
                        StatBadge(icon: "waveform.path.ecg", value: volatilityLabel)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? difficulty.color.opacity(0.15) : Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? difficulty.color.opacity(0.6) : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) {
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
    
    var volatilityLabel: String {
        switch difficulty.volatilityMultiplier {
        case ..<0.8: return "Low vol"
        case ..<1.5: return "Med vol"
        case ..<2.5: return "High vol"
        default: return "Extreme"
        }
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .medium))
            Text(value)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
        }
        .foregroundColor(.white.opacity(0.4))
    }
}
