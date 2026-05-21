//
//  CombatEffects.swift
//  ShamanDefense
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    // human gets hit
    func playHumanHitFlash(on target: GameEntity, color: SKColor = .white) {
        guard let root = target.component(ofType: SpriteComponent.self)?.node,
              let body = root.children.first(where: { $0 is SKSpriteNode }) as? SKSpriteNode else { return }

        body.removeAction(forKey: "human_hit_flash")
        body.run(.sequence([
            .colorize(with: color, colorBlendFactor: 0.35, duration: 0.1),
            .colorize(withColorBlendFactor: 0.0, duration: 0.08)
        ]), withKey: "human_hit_flash")

        if let sprite = target.component(ofType: SpriteComponent.self) {
            let impact = SKShapeNode()
            let p = CGMutablePath()
            p.move(to: CGPoint(x: 0, y: 14))
            p.addLine(to: CGPoint(x: 4, y: 4))
            p.addLine(to: CGPoint(x: 14, y: 0))
            p.addLine(to: CGPoint(x: 4, y: -4))
            p.addLine(to: CGPoint(x: 0, y: -14))
            p.addLine(to: CGPoint(x: -4, y: -4))
            p.addLine(to: CGPoint(x: -14, y: 0))
            p.addLine(to: CGPoint(x: -4, y: 4))
            p.closeSubpath()
            impact.path = p
            impact.position = sprite.position
            impact.fillColor = SKColor.white.withAlphaComponent(1.0)
            impact.strokeColor = SKColor(red: 1.0, green: 0.95, blue: 0.30, alpha: 1.0)
            impact.lineWidth = 2.0
            impact.zPosition = 40
            impact.blendMode = .add
            fxLayer.addChild(impact)
            impact.run(.sequence([
                .group([
                    .scale(to: 1.55, duration: 0.07),
                    .fadeOut(withDuration: 0.07)
                ]),
                .removeFromParent()
            ]))

            let impact2 = impact.copy() as! SKShapeNode
            impact2.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.10, alpha: 0.85)
            impact2.strokeColor = .white
            impact2.lineWidth = 1.4
            impact2.zPosition = 41
            impact2.setScale(0.72)
            fxLayer.addChild(impact2)
            impact2.run(.sequence([
                .group([
                    .scale(to: 1.25, duration: 0.06),
                    .fadeOut(withDuration: 0.06)
                ]),
                .removeFromParent()
            ]))

            let ring = SKShapeNode(circleOfRadius: 16)
            ring.position = sprite.position
            ring.fillColor = .clear
            ring.strokeColor = SKColor.white.withAlphaComponent(0.95)
            ring.lineWidth = 2.0
            ring.zPosition = 39
            ring.blendMode = .add
            fxLayer.addChild(ring)
            ring.run(.sequence([
                .group([
                    .scale(to: 1.28, duration: 0.09),
                    .fadeOut(withDuration: 0.09)
                ]),
                .removeFromParent()
            ]))
        }
    }

    //headbutt poci's hit
    func playHeadbuttHitReaction(on target: GameEntity) {
        guard let root = target.component(ofType: SpriteComponent.self)?.node,
              let body = root.children.first(where: { $0 is SKSpriteNode }) as? SKSpriteNode else { return }

        body.removeAction(forKey: "headbutt_hit_reaction")
        let originalPosition = body.position
        let punch = SKAction.sequence([
            .moveBy(x: 8, y: 0, duration: 0.03),
            .moveBy(x: -6, y: 0, duration: 0.03),
            .moveBy(x: 3, y: 0, duration: 0.02),
            .moveBy(x: -2, y: 0, duration: 0.02),
            .move(to: originalPosition, duration: 0.01)
        ])
        body.run(punch, withKey: "headbutt_hit_reaction")
    }
}
