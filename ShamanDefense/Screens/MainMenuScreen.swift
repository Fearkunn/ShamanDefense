//
//  MainMenuScreen.swift
//  ShamanDefense
//
//  Created by Michael on 15/05/26.
//

import Foundation
import Combine

final class MainMenuViewModel: ObservableObject {
    
    @Published var highScore: Int = 0
    
    func startGame() {
        print("Start Game")
    }
    
    func openCharacters() {
        print("Open Characters")
    }
    
    func openSettings() {
        print("Open Settings")
    }
}
