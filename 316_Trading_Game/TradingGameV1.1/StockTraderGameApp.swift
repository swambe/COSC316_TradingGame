import SwiftUI
import SwiftData

@main
struct StockTraderGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PlayerProfile.self, TradeRecord.self])
    }
}
