//
//  ScoreManager.swift
//  ShamanDefense
//
//  Created by Michael on 19/05/26.
//

import Foundation

class ScoreManager {

    static let shared = ScoreManager()
    private init() {}

    // MARK: - Keys

    private let highScoreKey = "highScore"
    private let hasPlayedKey = "hasPlayed"

    // MARK: - Has Played

    /// True jika user sudah pernah menyelesaikan minimal 1 game
    var hasPlayed: Bool {
        UserDefaults.standard.bool(forKey: hasPlayedKey)
    }

    // MARK: - High Score

    var highScore: Int {
        UserDefaults.standard.integer(forKey: highScoreKey)
    }

    // MARK: - Save

    /// Dipanggil saat game selesai (game over / menang)
    /// - Parameter score: skor akhir dari sesi game yang baru saja selesai
    func saveScore(_ score: Int) {
        // Tandai bahwa user sudah pernah main
        UserDefaults.standard.set(true, forKey: hasPlayedKey)

        // Update high score hanya jika lebih tinggi
        if score > highScore {
            UserDefaults.standard.set(score, forKey: highScoreKey)
        }
    }

    // MARK: - Reset (untuk keperluan testing / debug)

    func resetAll() {
        UserDefaults.standard.removeObject(forKey: highScoreKey)
        UserDefaults.standard.removeObject(forKey: hasPlayedKey)
    }
}
