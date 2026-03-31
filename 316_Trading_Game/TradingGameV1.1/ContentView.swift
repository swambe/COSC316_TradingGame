import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var gameVM = GameViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            switch gameVM.gamePhase {
            case .title:
                TitleView()
                    .transition(.opacity)
            case .difficultySelect:
                DifficultySelectView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .playing:
                GameBoardView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .roundSummary:
                RoundSummaryView()
                    .transition(.scale.combined(with: .opacity))
            case .gameOver:
                GameOverView()
                    .transition(.scale.combined(with: .opacity))
            case .leaderboard:
                LeaderboardView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .environmentObject(gameVM)
        .onAppear {
            gameVM.setModelContext(modelContext)
            gameVM.loadOrCreatePlayer()
        }
        .animation(.easeInOut(duration: 0.4), value: gameVM.gamePhase)
    }
}
