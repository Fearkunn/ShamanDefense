//
//  FiringComponent.swift
//  ShamanDefense
//

import GameplayKit

final class FiringComponent: GKComponent {
    let fireInterval: TimeInterval
    var cooldownRemaining: TimeInterval = 0

    init(fireInterval: TimeInterval) {
        self.fireInterval = fireInterval
        super.init()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    func resetCooldown() { cooldownRemaining = fireInterval }

    func tickCooldown(_ dt: TimeInterval) {
        cooldownRemaining = max(0, cooldownRemaining - dt)
    }

    var ready: Bool { cooldownRemaining <= 0 }
}
