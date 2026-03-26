//
//  Score.swift
//  316_Trading_Game
//
//  Created by Sam Blair on 2026-03-25.
//

import Foundation
import SwiftData

@Model class Score{
    var score: Int
    
    init(score: Int) {
        self.score = score
    }
    
    func getScore() -> Int{
        return self.score
    }
    
    func buy(amount: Int){
        self.score -= amount
    }
    
    func sell(amount: Int){
        self.score += amount
    }
}

