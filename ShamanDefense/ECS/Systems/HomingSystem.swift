//
//  HomingSystem.swift
//  ShamanDefense
//

import GameplayKit
import CoreGraphics

final class HomingSystem: ComponentSystem<HomingComponent> {
    override func update(deltaTime: TimeInterval) {
        for h in components {
            tick(h, dt: deltaTime)
        }
    }

    private func tick(_ h: HomingComponent, dt: TimeInterval) {
        guard let entity = h.entity as? GameEntity,
              let sprite = entity.component(ofType: SpriteComponent.self) else { return }

        guard let target = h.target,
              let targetSprite = target.component(ofType: SpriteComponent.self),
              targetSprite.node.parent != nil,
              let health = target.component(ofType: HealthComponent.self), health.isAlive else {
            h.onTargetLost?()
            return
        }

        var pos = sprite.position
        let dx = targetSprite.position.x - pos.x
        let dy = targetSprite.position.y - pos.y
        let dist = hypot(dx, dy)

        if dist <= h.hitRadius {
            h.onImpact?(pos, target)
            return
        }

        let step = h.speed * CGFloat(dt)
        if step >= dist {
            pos = targetSprite.position
        } else {
            pos.x += dx / dist * step
            pos.y += dy / dist * step
        }
        sprite.position = pos
    }
}
