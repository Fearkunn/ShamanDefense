//
//  ScoreComponent.swift
//  ShamanDefense
//

import GameplayKit

final class ScoreComponent: GKComponent {
    private let highScoreKey = "ShamanDefense_HighScore"
    private let hasPlayedKey = "ShamanDefense_HasPlayed"

    private(set) var current: Int = 0
    private(set) var high: Int

    var isFirstPlay: Bool {
        !UserDefaults.standard.bool(forKey: hasPlayedKey)
    }

    override init() {
        self.high = UserDefaults.standard.integer(forKey: highScoreKey)
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func add(_ points: Int = 1) {
        current += points
    }

    func saveAndFinalize() {
        UserDefaults.standard.set(true, forKey: hasPlayedKey)
        if current > high {
            high = current
            UserDefaults.standard.set(high, forKey: highScoreKey)
        }
    }
}
