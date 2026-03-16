//
//  TitleScreenView.swift
//  316_Trading_Game
//
//  Created by Sam Blair on 2026-02-12.
//

import SwiftUI

struct TitleScreenView: View {
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .background(Color.black)
            
            
            Text("Shorts and Ladders")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
        }
    }
}

#Preview {
    TitleScreenView()
}
