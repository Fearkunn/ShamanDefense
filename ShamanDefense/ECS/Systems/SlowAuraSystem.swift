//
//  SlowAuraSystem.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class SlowAuraSystem: ComponentSystem<SlowAuraComponent> {
    override func update(deltaTime: TimeInterval) {
        for aura in components {
            tick(aura, dt: deltaTime)
        }
    }

    private func tick(_ aura: SlowAuraComponent, dt: TimeInterval) {
        guard aura.active,
              let entity = aura.entity as? GameEntity,
              let sprite = entity.component(ofType: SpriteComponent.self),
              let scene = sprite.node.scene as? GameScene else { return }

        aura.accum += dt
        guard aura.accum >= aura.scanInterval else { return }
        aura.accum = 0

        for human in scene.registry.humans {
            guard let hp = human.component(ofType: SpriteComponent.self)?.position,
                  let health = human.component(ofType: HealthComponent.self), health.isAlive,
                  let effects = human.component(ofType: EffectsComponent.self) else { continue }
            if hypot(hp.x - sprite.position.x, hp.y - sprite.position.y) <= aura.radius {
                effects.applySlow(factor: aura.factor, duration: aura.duration)
            }
        }
    }
}
