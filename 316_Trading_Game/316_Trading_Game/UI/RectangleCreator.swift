//
//  RectangleCreator.swift
//  316_Trading_Game
//
//  Created by Sam Blair on 2026-03-25.
//

import SwiftUI

struct RectangleCreator {
    @ViewBuilder
    func createRectangle(height: Int, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(color)
            .frame(height: CGFloat(height))
    }
}

#Preview {
    VStack(spacing: 16) {
        RectangleCreator().createRectangle(height: 44, color: .red)
        RectangleCreator().createRectangle(height: 80, color: .green)
    }
    .padding()
}
