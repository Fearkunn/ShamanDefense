//
//  EffectsSystem.swift
//  ShamanDefense
//

import GameplayKit

final class EffectsSystem: ComponentSystem<EffectsComponent> {
    override func update(deltaTime: TimeInterval) {
        for fx in components {
            if fx.slowRemaining > 0 {
                fx.slowRemaining = max(0, fx.slowRemaining - deltaTime)
            }
            if fx.freezeRemaining > 0 {
                fx.freezeRemaining = max(0, fx.freezeRemaining - deltaTime)
            }
            if let entity = fx.entity as? GameEntity,
               let pf = entity.component(ofType: PathFollowComponent.self) {
                pf.speedMultiplier = fx.currentSpeedFactor
                pf.frozen = fx.isFrozen
            }
        }
    }
}
