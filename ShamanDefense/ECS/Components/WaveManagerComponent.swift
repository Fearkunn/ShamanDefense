//
//  WaveManagerComponent.swift
//  ShamanDefense
//

import Foundation
import CoreGraphics
import GameplayKit

enum WaveState {
    case intermission
    case spawning
    case resolving
    case stopped
}

final class WaveManagerComponent: GKComponent {
    var currentWave: Int = 0
    var state: WaveState = .intermission
    var stateTimer: TimeInterval = 0
    var pendingEntries: [SpawnEntry] = []
    var nextSpawnIn: TimeInterval = 0

    let config: WaveScalingConfig

    var onIntermission: ((Int) -> Void)?
    var onWaveStart: ((Int) -> Void)?
    var onSpawn: ((HumanArchetype, CGFloat) -> Void)?
    var humansAliveCount: (() -> Int)?

    init(config: WaveScalingConfig = .default) {
        self.config = config
        self.stateTimer = config.firstIntermission
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
