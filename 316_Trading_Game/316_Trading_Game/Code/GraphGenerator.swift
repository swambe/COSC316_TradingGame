//
//  GraphGenerator.swift
//  316_Trading_Game
//
//  Created by Sam Blair on 2026-02-12.
//

import SwiftUI

struct GraphGenerator {
    // MARK: - Stored Properties
    private var time: Int
    private var graphPoints: [Double]
    private var points: Int = 0

    var gameAlgorithm: Algorithm
    var currentLevel: Level

    // Expose level derived from gameAlgorithm
    var level: Int { gameAlgorithm.level }

    // MARK: - Initializers
    init(time: Int = 60, points: [Double] = [], difficulty: Algorithm.Difficulty = .easy()) {
        self.time = time
        self.graphPoints = []
        self.gameAlgorithm = Algorithm(difficulty: difficulty)
        self.currentLevel = .init()
    }
}
