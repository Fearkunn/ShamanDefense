//
//  ProjectileEntity.swift
//  ShamanDefense
//

import GameplayKit
import SpriteKit

final class ProjectileEntity: GameEntity {
    init(from origin: CGPoint, target: GameEntity, launcher: ProjectileLauncherComponent) {
        super.init(archetype: .projectile)

        let node: SKNode
        if launcher.sourceGhostID == .poci {
            let sprite = SKSpriteNode(imageNamed: "poci_headbutt")
            sprite.size = CGSize(width: 20, height: 20)
            sprite.position = origin
            sprite.zPosition = 5
            node = sprite
        } else {
            let shape = SKShapeNode(circleOfRadius: 4)
            shape.fillColor = launcher.color
            shape.strokeColor = .clear
            shape.position = origin
            shape.zPosition = 5
            node = shape
        }

        addComponent(SpriteComponent(node: node))
        addComponent(HomingComponent(target: target, speed: launcher.projectileSpeed, hitRadius: launcher.hitRadius))
        addComponent(DamageOnHitComponent(
            sourceGhostID: launcher.sourceGhostID,
            damage: launcher.damage,
            aoeRadius: launcher.aoeRadius,
            color: launcher.color
        ))
        addComponent(LifetimeComponent(duration: 3))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}
