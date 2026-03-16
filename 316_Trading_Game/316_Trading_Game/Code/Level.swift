//
//  SwiftUIView.swift
//  316_Trading_Game
//
//  Created by Sam Blair on 2026-03-13.
//

import SwiftUI
import Foundation

struct Level{
    
    //MARK: Data In
    var level: Int?
    
    //MARK: Data Out
    var levelEndPoints: Int
    
    init(level: Int = 1){
        self.level = level
        self.levelEndPoints = (level * 100000) / (2/level)
    }
    
}

