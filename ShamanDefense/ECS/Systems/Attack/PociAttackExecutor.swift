//
//  PociAttackExecutor.swift
//  ShamanDefense
//

import SpriteKit
import GameplayKit

struct PociAttackExecutor: GhostAttackExecutor {
    func execute(_ context: GhostAttackContext) {
        guard let targetSprite = context.target.component(ofType: SpriteComponent.self),
              let health = context.target.component(ofType: HealthComponent.self),
              health.isAlive else { return }

        if let aoe = context.launcher.aoeRadius {
            context.scene.applyAoEDamage(
                at: targetSprite.position,
                radius: aoe,
                amount: context.launcher.damage,
                color: context.launcher.color
            )
        } else {
            health.takeDamage(context.launcher.damage)
            context.scene.playHeadbuttHitReaction(on: context.target)
        }
    }
}
