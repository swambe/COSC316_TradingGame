//
//  GraphGenerator.swift
//  316_Trading_Game
//
//  Created by Sam Blair on 2026-02-12.
//

import SwiftUI

struct GraphGenerator {
    // MARK: Stored Properties
    private var time: Int
    private var graphPositivePoints: [Int]
    private var graphNegativePoints: [Int]
    private var points: Int = 0

    //MARK: Data In
    var startingStockValue: Int
    var level: Int

    // MARK: - Initializers
    init(time: Int = 60, points: [Double] = [], difficulty: Algorithm.Difficulty = .easy(), startingStockValue: Int = 100, level: Int) {
        self.time = time
        self.graphPositivePoints = []
        self.graphNegativePoints = []
        self.level = level
        self.startingStockValue = startingStockValue
    }
    
    mutating func addPoint(stockValue: Int){
        if stockValue > startingStockValue {
            graphPositivePoints.append(stockValue)
            graphNegativePoints.append(0)
        }else if stockValue < startingStockValue {
            graphPositivePoints.append(0)
            graphNegativePoints.append(stockValue)
        }else{
            graphPositivePoints.append(0)
            graphNegativePoints.append(0)
        }
    }
    
    func getPosPoints() -> [Int]{
        graphPositivePoints
    }
    func getNegPoints() -> [Int]{
        graphNegativePoints
    }
    
    mutating func finishLevel(startingStockValue: Int){
        graphNegativePoints.removeAll()
        graphPositivePoints.removeAll()
        time = 60
        self.startingStockValue = startingStockValue
    }
}
