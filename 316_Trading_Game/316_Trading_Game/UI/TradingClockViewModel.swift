//
//  TradingClockViewModel.swift
//  316_Trading_Game
//
//  Created by Sam Blair on 2026-03-25.
//

import Foundation
import Combine

final class TradingClockViewModel: ObservableObject {
    
    @Published var secondsElapsed: Int = 0  
    @Published var isRunning: Bool = true
    @Published var displayedTime: String = "09:00"

    var onTick: (() -> Void)?

    private var cancellable: AnyCancellable?

    init(onTick: (() -> Void)? = nil) {
        self.onTick = onTick
        start()
    }

    func start() {
        cancellable?.cancel()
        let publisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        cancellable = publisher.sink { [weak self] _ in
            self?.handleTick()
        }
    }

    func pause() { isRunning = false }

    func resume() { isRunning = true }

    func reset() {
        secondsElapsed = 0
        displayedTime = "09:00"
        isRunning = true
    }

    private func handleTick() {
        guard isRunning else { return }
        guard secondsElapsed < 60 else { return }

        secondsElapsed += 1
        
        let simulatedMinutesTotal = secondsElapsed * 8
        let startMinutes = 9 * 60 // 09:00
        let minutesFromMidnight = startMinutes + simulatedMinutesTotal

        let hours = (minutesFromMidnight / 60) % 24
        let minutes = minutesFromMidnight % 60
        displayedTime = String(format: "%02d:%02d", hours, minutes)

        onTick?()

        if secondsElapsed >= 60 {
            isRunning = false
        }
    }
}
