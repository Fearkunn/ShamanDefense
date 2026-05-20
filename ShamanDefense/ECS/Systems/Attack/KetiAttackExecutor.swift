//
//  KetiAttackExecutor.swift
//  ShamanDefense
//

import SpriteKit
import GameplayKit

struct KetiAttackExecutor: GhostAttackExecutor {
    func execute(_ context: GhostAttackContext) {
        guard let targetSprite = context.target.component(ofType: SpriteComponent.self),
              let health = context.target.component(ofType: HealthComponent.self),
              health.isAlive else { return }

        let targetPos = targetSprite.position
        let dx = targetPos.x - context.origin.x
        let dy = targetPos.y - context.origin.y
        let dist = max(hypot(dx, dy), 1)
        let dirX = dx / dist
        let dirY = dy / dist

        let mouthForward: CGFloat = CharacterSprites.spriteHeight * 0.62
        let mouthOrigin = CGPoint(
            x: context.origin.x + dirX * mouthForward,
            y: context.origin.y + dirY * mouthForward
        )
        let waveDuration: TimeInterval = 0.60

        for delay in [0.0, 0.05] {
            let wave = SKSpriteNode(imageNamed: "keti_effect")
            wave.size = CGSize(width: 24, height: 24)
            wave.position = mouthOrigin
            wave.zPosition = 12
            wave.alpha = 0.95
            wave.zRotation = atan2(dirY, dirX) + .pi
            context.scene.fxLayer.addChild(wave)
            wave.run(.sequence([
                .wait(forDuration: delay),
                .group([
                    .move(to: targetPos, duration: waveDuration),
                    .scale(to: 1.45, duration: waveDuration),
                    .fadeOut(withDuration: waveDuration)
                ]),
                .removeFromParent()
            ]))
        }

        if let aoe = context.launcher.aoeRadius {
            context.scene.applyAoEDamage(
                at: targetPos,
                radius: aoe,
                amount: context.launcher.damage,
                color: context.launcher.color
            )
        } else if health.isAlive,
                  context.target.component(ofType: SpriteComponent.self)?.node.parent != nil {
            health.takeDamage(context.launcher.damage)
        }
    }
}
