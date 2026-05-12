//
//  ScoreManager.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 12/05/26.
//

import Foundation

class ScoreManager {
    
    private let highScoreKey = "ShamanDefense_HighScore"
    private let hasPlayedKey = "ShamanDefense_HasPlayed"
    
    private(set) var currentScore: Int = 0
    private(set) var highScore: Int = 0
    
    var isFirstPlay: Bool {
        !UserDefaults.standard.bool(forKey: hasPlayedKey)
    }
    
    init() {
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
    func addScore(_ points: Int = 1) {
        currentScore += points
    }
    
    func saveAndFinalize() {
        UserDefaults.standard.set(true, forKey: hasPlayedKey)
        if currentScore > highScore {
            highScore = currentScore
            UserDefaults.standard.set(highScore, forKey: highScoreKey)
        }
    }
    
    func reset() {
        currentScore = 0
    }
}
