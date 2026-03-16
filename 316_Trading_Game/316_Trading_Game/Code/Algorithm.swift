//
//  Algorithm.swift
//  316_Trading_Game
//
//  Created by Sam Blair on 2026-03-13.
//

import SwiftUI
import Foundation

struct Algorithm{
    
    //MARK: Data Owned By Me
    var level: Int = 1
    
    let difficulty: Difficulty
    
    enum Difficulty {
        case easy(variance: Double = 0.2)
        case medium(variance: Double = 0.4)
        case hard(variance: Double = 0.8)
    }
    
    init(difficulty: Difficulty = .easy(variance: 0.2)) {
        self.difficulty = difficulty
    }
    
    mutating func nextPoint(lastPoint: Double) -> Double{
        let variance: Double
        switch difficulty {
        case .easy(let v), .medium(let v), .hard(let v):
            variance = v
        }
        let delta = (Double.random(in: -1...1)) * variance * Double(level)
        return lastPoint + delta
    }
    
    mutating func levelUp(){
        self.level = level + 1
        
    }
}

