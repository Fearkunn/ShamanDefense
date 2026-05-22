//
//  GugunAttackExecutor.swift
//  ShamanDefense
//

import SpriteKit
import GameplayKit

struct GugunAttackExecutor: GhostAttackExecutor {
    func execute(_ context: GhostAttackContext) {
        guard let sourceRoot = context.source.component(ofType: SpriteComponent.self)?.node else { return }
        let initialTargetPosition = context.target.component(ofType: SpriteComponent.self)?.position ?? context.origin

        // Jump in place animation
        sourceRoot.removeAction(forKey: "gugun_jump_attack")
        sourceRoot.run(
            .sequence([
                .group([
                    .moveBy(x: 0, y: 12, duration: 0.10),
                    .scale(to: 1.08, duration: 0.10)
                ]),
                .group([
                    .moveBy(x: 0, y: -12, duration: 0.12),
                    .scale(to: 1.0, duration: 0.12)
                ])
            ]),
            withKey: "gugun_jump_attack"
        )

        let hitDelay: TimeInterval = 0.18
        context.scene.run(.sequence([
            .wait(forDuration: hitDelay),
            .run { [weak scene = context.scene, weak target = context.target] in
                guard let scene else { return }
                let impactPoint =
                    target?.component(ofType: SpriteComponent.self)?.position
                    ?? initialTargetPosition
                if let aoe = context.launcher.aoeRadius {
                    let footPoint = CGPoint(
                        x: context.origin.x,
                        y: context.origin.y - CharacterSprites.spriteHeight * 0.50
                    )
                    let stomp = SKShapeNode(ellipseOf: CGSize(width: 26, height: 11))
                    stomp.position = footPoint
                    stomp.fillColor = SKColor(white: 0.20, alpha: 0.20)
                    stomp.strokeColor = SKColor(white: 0.60, alpha: 0.35)
                    stomp.lineWidth = 1.2
                    stomp.zPosition = 11
                    scene.fxLayer.addChild(stomp)
                    stomp.run(.sequence([
                        .group([
                            .scaleX(to: 2.2, y: 1.6, duration: 0.16),
                            .fadeOut(withDuration: 0.16)
                        ]),
                        .removeFromParent()
                    ]))

                    for puffOffset: CGFloat in [-10, 0, 10] {
                        let puff = SKShapeNode(circleOfRadius: 5)
                        puff.position = CGPoint(x: footPoint.x + puffOffset, y: footPoint.y + 1)
                        puff.fillColor = SKColor(white: 0.82, alpha: 0.35)
                        puff.strokeColor = .clear
                        puff.zPosition = 12
                        scene.fxLayer.addChild(puff)
                        puff.run(.sequence([
                            .group([
                                .moveBy(x: puffOffset * 0.45, y: 1, duration: 0.18),
                                .scale(to: 1.7, duration: 0.18),
                                .fadeOut(withDuration: 0.18)
                            ]),
                            .removeFromParent()
                        ]))
                    }

                    scene.applyAoEDamage(
                        at: impactPoint,
                        radius: aoe,
                        amount: context.launcher.damage,
                        color: context.launcher.color,
                        showsFlash: false
                    )
                    scene.playGugunMultiTargetPulse(at: impactPoint, radius: aoe)
                } else if let target,
                          let health = target.component(ofType: HealthComponent.self),
                          health.isAlive {
                    scene.playHumanHitFlash(on: target, color: context.launcher.color)
                    health.takeDamage(context.launcher.damage)
                }
            }
        ]))
    }
}
