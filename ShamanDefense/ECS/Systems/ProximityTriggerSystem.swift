//
//  ProximityTriggerSystem.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class ProximityTriggerSystem: ComponentSystem<ProximityTriggerComponent> {
    override func update(deltaTime: TimeInterval) {
        for trigger in components {
            tick(trigger)
        }
    }

    private func tick(_ trigger: ProximityTriggerComponent) {
        guard trigger.armed,
              let entity = trigger.entity as? GameEntity,
              let sprite = entity.component(ofType: SpriteComponent.self),
              let scene = sprite.node.scene as? GameScene else { return }

        for human in scene.registry.humans {
            guard let h = human.component(ofType: HealthComponent.self), h.isAlive,
                  let hp = human.component(ofType: SpriteComponent.self)?.position else { continue }
            if hypot(hp.x - sprite.position.x, hp.y - sprite.position.y) <= trigger.triggerRadius {
                trigger.armed = false
                trigger.onTrigger?(human)
                return
            }
        }
    }
}
