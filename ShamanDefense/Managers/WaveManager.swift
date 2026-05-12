//
//  WaveManager.swift
//  ShamanDefense
//
//  Created by Richie Daryl Kwenandar on 07/05/26.
//

import SpriteKit

class WaveManager {

    private weak var scene: GameScene?
    private let waypoints: [CGPoint]
    private let tileSize: CGFloat
    private let spawnInterval: TimeInterval = 3

    init(scene: GameScene, waypoints: [CGPoint], tileSize: CGFloat = 36) {
        self.scene     = scene
        self.waypoints = waypoints
        self.tileSize  = tileSize
    }

    func start() {
        spawnOne()
        scene?.run(.repeatForever(.sequence([
            .wait(forDuration: spawnInterval),
            .run { [weak self] in self?.spawnOne() }
        ])))
    }
    
    func stop() {
        scene?.removeAllActions()
    }

    private func spawnOne() {
        guard let scene else { return }
        let human = HumanNode()
        human.onDefeat = { [weak scene] in scene?.humanDefeated() }
        
        scene.addChild(human)
        human.followPath(waypoints) { [weak scene] in
                    scene?.humanReachedFinish()
                }
    }
}
