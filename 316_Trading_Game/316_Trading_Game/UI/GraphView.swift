//
//  GraphView.swift
//  316_Trading_Game
//
//  Created by Sam Blair on 2026-02-12.
//

import SwiftUI

struct GraphView: View {
    // MARK: - Game dependencies (kept as in original where reasonable)
    @State private var rectangleCreator = RectangleCreator()
    @State private var currentLevel = Level(level: 1)
    @State private var gameScore = Score(score: 0)
    @State private var gameAlgorithm: Algorithm = Algorithm(difficulty: .easy(variance: 0.2))
    @State private var gameGraph = GraphGenerator(level: 1)
    
    @StateObject private var clock = TradingClockViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            Text(clock.displayedTime)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            VStack {
                HStack(alignment: .bottom) {
                    ForEach(gameGraph.getPosPoints().indices, id: \.self) { index in
                        rectangleCreator.createRectangle(height: gameAlgorithm.getDifference(value: index), color: .green)
                    }
                }
                HStack(alignment: .top) {
                    ForEach(gameGraph.getNegPoints().indices, id: \.self) { index in
                        rectangleCreator.createRectangle(height: gameAlgorithm.getDifference(value: index), color: .red)
                    }
                }
            }
            .onAppear {
                clock.onTick = {
                    gameGraph.addPoint(stockValue: gameAlgorithm.nextPoint(lastValue: gameAlgorithm.getCurrentValue()))
                }
            }
        }
    }
}

#Preview {
    GraphView()
}

