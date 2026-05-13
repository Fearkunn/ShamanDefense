//
//  LifetimeSystem.swift
//  ShamanDefense
//

import GameplayKit

final class LifetimeSystem: ComponentSystem<LifetimeComponent> {
    override func update(deltaTime: TimeInterval) {
        for life in components {
            guard life.remaining > 0 else { continue }
            life.remaining -= deltaTime
            if life.remaining <= 0 {
                life.onExpire?()
            }
        }
    }
}
